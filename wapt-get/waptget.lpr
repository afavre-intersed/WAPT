program waptget;
{ -----------------------------------------------------------------------
#    This file is part of WAPT
#    Copyright (C) 2013  Tranquil IT Systems http://www.tranquil.it
#    WAPT aims to help Windows systems administrators to deploy
#    setup and update applications on users PC.
#
#    WAPT is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    WAPT is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with WAPT.  If not, see <http://www.gnu.org/licenses/>.
#
# -----------------------------------------------------------------------
}

{$mode objfpc}{$H+}
{$modeswitch typehelpers}

uses
  {$IFDEF UNIX}
  cthreads,
 {$ENDIF}
  Classes, CustApp,SysUtils,
  { you can add units after this }
  Interfaces, Windows, PythonEngine, VarPyth, superobject, soutils, tislogging, uWaptRes,
  waptcommon, waptutils, tiscommon, tisstrings, LazFileUtils, FileUtil,
  IdAuthentication, Variants, IniFiles,uwaptcrypto,uWaptPythonUtils,
  tisinifiles,base64,IdComponent,httpsend,uWAPTPollThreads;


type

  { PWaptGet }

  PWaptGet = class(TCustomApplication)
  private
    localuser,localpassword:AnsiString;
    FRepoURL: String;
    FLastProgressMs:DWORD;
    procedure DoOnProgress(Sender: TObject);
    procedure DoOnHttpWork(ASender: TObject; AWorkMode: TWorkMode; AWorkCount: Int64);


    function GetIsEnterpriseEdition: Boolean;
    function GetLocalWaptserverRepositoryPath: String;
    function GetPythonEngine: TPythonEngine;
    function GetRepoURL: String;
    function Getwaptcrypto: Variant;
    function Getwaptpackage: Variant;
    function Getwaptdevutils: Variant;
    procedure HTTPLogin(Sender: THttpSend; var ShouldRetry: Boolean;RetryCount:integer);
    function NextPackageVersion(RepoPath, PackageName, BaseVersion: String
      ): String;
    function PackageVersion(RepoPath,PackageName: String): String;
    function ScanLocalWaptrepo(RepoPath: String): Variant;
    procedure SetRepoURL(AValue: String);
  protected
    FPythonEngine: TPythonEngine;
    Fwaptcrypto,
    fwaptpackage,
    Fwaptdevutils: Variant;
    procedure DoRun; override;
  public
    Action : String;
    RegWaptBaseDir:String;
    CheckEventsThread: TCheckEventsThread;

    lock:TRTLCriticalSection;
    tasks:ISuperObject;
    lastMessageTime : TDateTime;


    constructor Create(TheOwner: TComponent); override;
    destructor Destroy; override;
    procedure WriteHelp; virtual;
    property RepoURL:String read GetRepoURL write SetRepoURL;

    procedure OnCheckEventsThreadNotify(Sender: TObject);

    function remainingtasks:ISuperObject;

    function GetCommonNameFromCmdLine(): String;

    function CheckPersonalCertificateIsCodeSigning(PersonalCertificatePath,PrivateKeyPassword:String): Boolean;
    function BuildWaptUpgrade(PackageName,Version,BuildDir,SetupFilename: String): String;
    procedure UploadWaptAgentUpgrade(SetupFilename, WaptUpgradeFilename: String);

    function CreateWaptAgent(BuildDir: String; Edition: String='waptagent'
      ): String;

    function CreateKeycert(commonname: String; basedir: String='';keypassword: String='';
        CodeSigning:Boolean=True;
        CA:Boolean=False;
        ClientAuth:Boolean=True;
        Overwrite:Boolean=False): String;

    function GetCAKeyPassword(crtname:String): String;
    function GetPrivateKeyPassword(crtname:String=''): String;
    function GetWaptServerPassword: String;
    function GetWaptServerUser: String;

    function GetWaptServicePassword: String;
    function GetWaptServiceUser: String;


    property PythonEngine:TPythonEngine read GetPythonEngine;
    property waptdevutils:Variant read Getwaptdevutils;
    property waptcrypto:Variant read Getwaptcrypto;
    property waptpackage:Variant read Getwaptpackage;

    property IsEnterpriseEdition:Boolean read GetIsEnterpriseEdition;
  end;

{ PWaptGet }

var
  Application: PWaptGet;

  function GetPassword(const InputMask: Char = '*'): string;
  var
    OldMode: Cardinal;
    c: char;
  begin
    Result:='';
    GetConsoleMode(GetStdHandle(STD_INPUT_HANDLE), OldMode);
    SetConsoleMode(GetStdHandle(STD_INPUT_HANDLE), OldMode and not (ENABLE_LINE_INPUT or ENABLE_ECHO_INPUT));
    try
      while not Eof do
      begin
        Read(c);
        if c = #13 then // Carriage Return
          Break;
        if (c = #8) then  // Back Space
        begin
          if (Length(Result) > 0) then
          begin
            Delete(Result, Length(Result), 1);
            Write(#8);
          end;
        end
        else
        begin
          Result := Result + c;
          Write(InputMask);
        end;
      end;
    finally
      SetConsoleMode(GetStdHandle(STD_INPUT_HANDLE), OldMode);
    end;
  end;


procedure PWaptGet.HTTPLogin(Sender: THttpSend; var ShouldRetry: Boolean; RetryCount:integer);
var
  newuser:AnsiString;
begin
  if (RetryCount<=1) then
  begin
    Sender.Username := GetWaptServiceUser;
    Sender.Password := GetWaptServicePassword;
  end
  else
  begin
    Write('Waptservice User ('+localuser+') :');
    readln(newuser);
    if newuser<>'' then
      Sender.Username:=newuser
    else
      Sender.Username:=localuser;
    if (Sender.Username='') then
      raise Exception.Create('Empty user');
    Write('Password: ');
    Sender.Password := GetPassword;
    WriteLn;
  end;
  // cache for next use
  localuser := Sender.Username;
  localpassword := Sender.Password;
  ShouldRetry := (Sender.Password <> '') and (Sender.Password <> '');
end;

// return the version for new waptupgrade package, be sure it is higer version than current one in repo
function PWaptGet.NextPackageVersion(RepoPath,PackageName,BaseVersion:String):String;
var
  LocalRepo,Package:Variant;
  OldVersion, OldBaseVersion: String;
  OldBuild: integer;
begin
  if PackageName = '' then
    PackageName := DefaultPackagePrefix+'-waptupgrade';
  LocalRepo := waptpackage.WaptLocalRepo(RepoPath);
  Package := LocalRepo.get(PackageName);
  if VarIsNone(Package) then
    Result := BaseVersion+'-0'
  else
  begin
    OldVersion := VarPythonAsString(Package.version);
    OldBaseVersion := StrSplit(OldVersion,'-',True,2)[0];
    if OldBaseVersion=BaseVersion then
    begin
      OldBuild := StrToInt(StrSplit(OldVersion,'-',True,2)[1]);
      Result := BaseVersion+'-'+IntToStr(OldBuild+1);
    end
    else
      Result := BaseVersion+'-0';
  end;
end;

function PWaptGet.PackageVersion(RepoPath,PackageName: String): String;
var
  LocalRepo,Package:Variant;
begin
  LocalRepo := waptpackage.WaptLocalRepo(RepoPath);
  Package := LocalRepo.get(PackageName);
  if VarIsNone(Package) then
    Result := ''
  else
    Result := VarPythonAsString(Package.version);
end;

function PWaptGet.GetWaptServerUser: String;
begin
  Result := GetCmdParams('WaptServerUser','');
  if Result = '' then
     Result := GetCmdParams('wapt-server-user','');
  while Result='' do
  begin
    Write('Waptserver '+GetWaptServerURL+' Admin User ('+WaptServerUser+') :');
    readln(Result);
    if result = '' then
      Result := WaptServerUser;
    WaptServerUser := Result;
  end;
  WaptServerUser := Result;
end;

function PWaptGet.GetWaptServerPassword: String;
begin
  if (WaptServerPassword='') and (GetCmdParams('WaptServerPassword64')<>'') then
    WaptServerPassword := DecodeStringBase64(GetCmdParams('WaptServerPassword64',''));
  if WaptServerPassword='' then
    WaptServerPassword := GetCmdParams('WaptServerPassword','');
  if WaptServerPassword='' then
    WaptServerPassword := GetCmdParams('wapt-server-passwd','');
  while WaptServerPassword='' do
  begin
    Write('Waptserver Password: ');
    WaptServerPassword := GetPassword;
    WriteLn;
  end;
  Result := WaptServerPassword;
end;

function PWaptGet.GetWaptServiceUser: String;
begin
  Result := GetCmdParams('WaptServiceUser','');
  if Result='' then
  begin
    Write('Waptservice User :');
    readln(Result);
  end;
end;

function PWaptGet.GetWaptServicePassword: String;
begin
  Result := '';
  if (GetCmdParams('WaptServicePassword64')<>'') then
    result := DecodeStringBase64(GetCmdParams('WaptServicePassword64',''));
  if result='' then
    result := GetCmdParams('WaptServicePassword','');
  if result='' then
  begin
    Write('Password: ');
    Result := GetPassword;
    WriteLn;
  end;
end;

function PWaptGet.GetPrivateKeyPassword(crtname:String=''): String;
begin
  if crtname ='' then
    crtname:=WaptPersonalCertificatePath;
  Result := '';
  if GetCmdParams('PrivateKeyPassword64')<>'' then
    result := DecodeStringBase64(GetCmdParams('PrivateKeyPassword64'));
  if result='' then
    result := GetCmdParams('PrivateKeyPassword','');
  if result='' then
  begin
    try
       result := FileToString(GetCmdParams('w',''));
    except
      result:=GetCmdParams('w','');
    end;
  end;
  while Result='' do
  begin
    Write('Private key Password for '+crtname+' : ');
    Result := GetPassword;
    WriteLn;
  end;
end;

function PWaptGet.GetCommonNameFromCmdLine(): String;
begin
  Result := '';
  if GetCmdParams('CommonName64')<>'' then
    result := DecodeStringBase64(GetCmdParams('CommonName64'));
  if result='' then
    result := GetCmdParams('CommonName','');
end;

function PWaptGet.CheckPersonalCertificateIsCodeSigning(
  PersonalCertificatePath, PrivateKeyPassword: String): Boolean;
var
  Certificate,PrivateKey: Variant;
begin
  try
    Certificate := waptcrypto.SSLCertificate(PyUTF8Decode(PersonalCertificatePath));
    // as boolean raises a invalid variant op... to
    if not VarIsTrue(Certificate.is_code_signing) then
        Raise Exception.CreateFmt('ERROR Personal Certificate is not a code signing certificate: %s',[PersonalCertificatePath]);

    PrivateKey := Certificate.matching_key_in_dirs(private_key_password := PrivateKeyPassword);
    if VarIsNull(PrivateKey) or VarIsNone(PrivateKey) then
      Raise Exception.CreateFmt('ERROR No matching private key found with supplied password for : %s',[PersonalCertificatePath]);

    Writeln('OK cert is codeSigning and found a matching private key path: '+VarPythonAsString(PrivateKey.private_key_filename));
    Result := True;
  except
    on E: Exception do
      begin
        Writeln('ERROR CheckPersonalCertificateIsCodeSigning: '+E.Message);
        Result := False;
      end;
  end;
end;

function PWaptGet.GetCAKeyPassword(crtname:String): String;
begin
  result := GetCmdParams('CAKeyPassword','');
  while Result='' do
  begin
    Write('CA key Password for '+crtname+' : ');
    Result := GetPassword;
    WriteLn;
  end;
end;


function PWaptGet.GetRepoURL: String;
begin
  if FRepoURL='' then
    FRepoURL:=GetMainWaptRepoURL;
  result := FRepoURL;
end;

function PWaptGet.Getwaptcrypto: Variant;
begin
  if not Assigned(PythonEngine) then
    Raise Exception.Create('No python engine available');
  if VarIsEmpty(Fwaptcrypto) or VarIsNull(Fwaptcrypto) then
    Fwaptcrypto:= VarPyth.Import('waptcrypto');
  Result := Fwaptcrypto;
end;


function PWaptGet.Getwaptpackage: Variant;
begin
  if not Assigned(PythonEngine) then
    Raise Exception.Create('No python engine available');
  if VarIsEmpty(Fwaptpackage) or VarIsNull(Fwaptpackage) then
    Fwaptpackage:= VarPyth.Import('waptpackage');
  Result := Fwaptpackage;
end;

function PWaptGet.GetIsEnterpriseEdition: Boolean;
begin
  {$ifdef ENTERPRISE}
  Result := True;
  {$else}
  Result := False;
  {$endif}
end;

function PWaptGet.GetPythonEngine: TPythonEngine;
begin
  if not Assigned(FPythonEngine) then
  begin
    // Running python stuff
    FPythonEngine := TPythonEngine.Create(Nil);

    RegWaptBaseDir:=WaptBaseDir();
    if not FileExistsUTF8(AppendPathDelim(RegWaptBaseDir)+'python27.dll') then
      RegWaptBaseDir:=RegisteredAppInstallLocation('wapt_is1');
    if not FileExistsUTF8(AppendPathDelim(RegWaptBaseDir)+'python27.dll') then
      RegWaptBaseDir:=RegisteredAppInstallLocation('WAPT Server_is1');
    if RegWaptBaseDir='' then
      RegWaptBaseDir:=ExtractFilePath(RegisteredExePath('wapt-get.exe'));

    with FPythonEngine do
    begin
      AutoLoad:=False;
      DllPath := RegWaptBaseDir;
      DllName := 'python27.dll';
      UseLastKnownVersion := False;
      SetPythonHome(RegWaptBaseDir);
      LoadDll;
    end;
  end;
  result := FPythonEngine;
end;

procedure PWaptGet.SetRepoURL(AValue: String);
begin
  if FRepoURL=AValue then Exit;
  FRepoURL:=AValue;
end;

function PWaptGet.GetLocalWaptserverRepositoryPath:String;
begin
  // todo use waptserver.ini config file for location
  Result := AppendPathDelim(WaptBaseDir)+'waptserver\repository\wapt';
end;

procedure PWaptGet.DoRun;
var
  MainModule : TStringList;
  WaptAgentFilename, WaptUpgradeFilename, TmpBuildDir, logleveloption : String;
  Res,task:ISuperobject;
  package,sopackages:ISuperObject;

  procedure SetFlag( AFlag: PInt; AValue : Boolean );
  begin
    if AValue then
      AFlag^ := 1
    else
      AFlag^ := 0;
  end;

var
  i:integer;
  NextIsParamValue:Boolean;
  NewCertificateFilename,DestCertPath:String;
  Args: TStringArray;

begin
  Action:='';
  sopackages  := TSuperObject.Create(stArray);

  NextIsParamValue := False;

  for i:=1 to ParamCount do
  begin
    if (Pos('-',Params[i])<>1) and not NextIsParamValue then
    begin
      if (action='') then
        Action := lowercase(Params[i])
      else
        sopackages.AsArray.Add(Params[i]);
      NextIsParamValue := False;
    end
    else
      NextIsParamValue := StrIsOneOf(Params[i],['-c','-r','-l','-p','-s','-e','-k','-w','-U','-g','-t','-L'])
  end;

  // parse parameters
  if HasOption('?') or HasOption('h','help') then
  begin
    writeln(utf8decode(rsOptRepo));
    writeln(utf8decode(rsWaptgetHelp));
  end;

  try
    {$ifdef windows}
    if HasOption('y','hide') then
      ShowWindow(GetConsoleWindow, SW_HIDE);
    {$endif}

    if HasOption('c','config') then
      ReadWaptConfig(GetOptionValue('c','config'))
    else
      ReadWaptConfig();

    if HasOption('r','repo') then
      RepoURL := GetOptionValue('r','repo');

    if HasOption('l','loglevel') then
    begin
      logleveloption := UpperCase(GetOptionValue('l','loglevel'));
      if logleveloption = 'DEBUG' then
        currentLogLevel := DEBUG
      else if logleveloption = 'INFO' then
        currentLogLevel := INFO
      else if logleveloption = 'WARNING' then
        currentLogLevel := WARNING
      else if logleveloption = 'ERROR' then
        currentLogLevel := ERROR
      else if logleveloption = 'CRITICAL' then
        currentLogLevel := CRITICAL;
      Logger('Current loglevel : '+StrLogLevel[currentLogLevel],DEBUG);
    end;

    if HasOption('v','version') then
      writeln(format(rsWin32exeWrapper, [ApplicationName, GetApplicationVersion]));

    if (action = 'create-keycert') then
    begin
      ReadWaptConfig(AppIniFilename('waptconsole'));
      NewCertificateFilename := CreateKeycert(GetCommonNameFromCmdLine,'','',
          GetCmdParams('CodeSigning','1')='1',
          GetCmdParams('CA','1')='1',
          GetCmdParams('ClientAuth','1')='1',
          FindCmdLineSwitch('Force',['/','-'],True) or FindCmdLineSwitch('F',['/','-'],True));

      if FindCmdLineSwitch('EnrollNewCert') then
      begin
        DestCertPath := AppendPathDelim(WaptBaseDir)+'ssl\'+ExtractFileName(NewCertificateFilename);
        if CopyFileW(PWideChar(UTF8Decode(NewCertificateFilename)),PWideChar(UTF8Decode(DestCertPath)),False) then
          WriteLn('Enrolled in: '+DestCertPath)
        else
        begin
          writeln('ERROR: Unable to copy certificate to '+DestCertPath);
          ExitProcess(3);
        end;

      end;
      if FindCmdLineSwitch('SetAsDefaultPersonalCert') then
      begin
        IniWriteString(AppIniFilename('waptconsole'),'global','personal_certificate_path',NewCertificateFilename);
        WriteLn('Personal Certificate config filename: '+AppIniFilename);
      end;
    end
    else
    if (action = 'check-valid-codesigning-cert') then
    begin
      ReadWaptConfig(AppIniFilename('waptconsole'));
      writeln(CheckPersonalCertificateIsCodeSigning(WaptPersonalCertificatePath,GetPrivateKeyPassword(WaptPersonalCertificatePath)));
    end
    else
    if (action = 'build-waptagent') then
    begin
      ReadWaptConfig(AppIniFilename('waptconsole'));
      Writeln(rsBuildWaptAgent);
      TmpBuildDir := GetTempFileNameUTF8('','wapt'+FormatDateTime('yyyymmdd"T"hhnnss',Now));
      try
        WaptAgentFilename := CreateWaptagent(TmpBuildDir);
        WaptUpgradeFilename := BuildWaptUpgrade(DefaultPackagePrefix+'-waptupgrade',
              NextPackageVersion(GetLocalWaptserverRepositoryPath,DefaultPackagePrefix+'-waptupgrade',
                    GetApplicationVersion(WaptAgentFilename)),
              TmpBuildDir,WaptAgentFilename);
        if FindCmdLineSwitch('DeployWaptAgentLocally') then
        begin
          if not DirectoryExistsUTF8(GetLocalWaptserverRepositoryPath) then
            Raise Exception.CreateFmt('Local repository %s does not exist',[GetLocalWaptserverRepositoryPath]);

          if CopyFileW(
              PWideChar(UTF8Decode(WaptAgentFilename)),
              PWideChar(UTF8Decode(AppendPathDelim(GetLocalWaptserverRepositoryPath)+'waptagent.exe')),
              False) then
            Writeln('waptagent copied to: '+AppendPathDelim(GetLocalWaptserverRepositoryPath)+'waptagent.exe')
          else
          begin
            Writeln('Fails to copy waptagent to repository location');
            ExitProcess(3);
          end;
          if CopyFileW(
              PWideChar(UTF8Decode(WaptUpgradeFilename)),
              PWideChar(UTF8Decode(AppendPathDelim(GetLocalWaptserverRepositoryPath)+ExtractFileName(WaptUpgradeFilename))),
              False) then
          begin
            Writeln('waptupgrade package copied to repository: '+WaptUpgradeFilename);
            ScanLocalWaptrepo(GetLocalWaptserverRepositoryPath);
            Writeln('local repository packages scan: OK');
          end
          else
          begin
            Writeln('Fails to copy waptagent to repository location');
            ExitProcess(3);
          end;
          Terminate;
          Exit;
        end
        else
        begin
          Writeln(rsBuildWaptUpgradePackage);
          GetWaptServerUser;
          GetWaptServerPassword;
          Writeln(rsUploadWaptAgent);
          UploadWaptAgentUpgrade(WaptAgentFilename,WaptUpgradeFilename);
          Terminate;
          Exit;
        end;
      finally
        If DirectoryExistsUTF8(TmpBuildDir) then
          DeleteDirectory(TmpBuildDir,False);
      end
    end
    else
    if (action = 'waptupgrade') then
    begin
      Writeln(format(rsWaptGetUpgrade, [RepoURL]));
      UpdateApplication(RepoURL+'/waptagent.exe','waptagent.exe','/VERYSILENT','wapt-get.exe','');
      Terminate;
      Exit;
    end
    else
    if (action = 'dnsdebug') then
    begin
      WriteLn(format(rsDNSserver, [Join(',',GetDNSServers)]));
      WriteLn(format(rsDNSdomain, [GetDNSDomain]));
      Writeln(utf8decode(format(rsMainRepoURL, [RepoURL])));
      Writeln(format(rsSRVwapt, [DNSSRVQuery('_wapt._tcp.'+GetDNSDomain).AsJSon(True)]));
      Writeln(format(rsSRVwaptserver, [DNSSRVQuery('_waptserver._tcp.'+GetDNSDomain).AsJSon(True)]));
      Writeln(format(rsCNAME, [DNSCNAMEQuery('wapt.'+GetDNSDomain).AsJSon(True)]));
      Terminate;
      Exit;
    end
    else
    // use http service mode if --service or not --direct or not (--service) and isadmin
    if  ((not IsAdminLoggedOn or HasOption('S','service')) and not HasOption('D','direct')) and
        StrIsOneOf(action,['update','upgrade','register','install','remove','forget',
                          'longtask','cancel','cancel-all','tasks',
                          'wuascan','wuadownload','wuainstall','audit']) and
        CheckOpenPort('127.0.0.1',waptservice_port,waptservice_timeout*1000) then
    begin
      writeln('About to speak to waptservice...');
      // launch task in waptservice, waits for its termination
      CheckEventsThread :=TCheckEventsThread.Create(@Self.OnCheckEventsThreadNotify);
      CheckEventsThread.Start;
      lastMessageTime := Now;
      tasks := TSuperObject.create(stArray);
      try
        try
          res := Nil;
          //test longtask
          Args := TStringArray.Create(Format('notify_user=%s',[GetCmdParams('notify_user','1')]));
          if HasOption('notify_server_on_start') then
            Args.Append('notify_server_on_start='+GetCmdParams('notify_server_on_start','0'));
          if HasOption('notify_server_on_finish') then
            Args.Append('notify_server_on_finish='+GetCmdParams('notify_server_on_finish','0'));
          if HasOption('f','force') then
            Args.Append('force=1');

          if action='longtask' then
          begin
            Logger('Call longtask URL...',DEBUG);
            res := WAPTLocalJsonGet(Format('longtask.json?%s',[StrJoin('&',Args)]),'admin','',-1,@HTTPLogin,3);
            tasks.AsArray.Add(res);
            Logger('Task '+res.S['id']+' added to queue',DEBUG);
          end
          else
          if action='tasks' then
          begin
            res := WAPTLocalJsonGet(Format('tasks.json?%s',[StrJoin('&',Args)]));
            if (res<>Nil) then
            begin
              if (res['running'].DataType<>stNull) then
                writeln(utf8decode(format(rsRunningTask,[ res['running'].I['id'],res['running'].S['description'],res['running'].S['runstatus']])))
              else
                writeln(utf8decode(rsNoRunningTask));
              if res['pending'].AsArray.length>0 then
              begin
                writeln(utf8decode(rsPending));
                for task in res['pending'] do
                  writeln(utf8encode('  '+task.S['id']+' '+task.S['description']));
              end;
            end;
          end
          else
          if action='cancel' then
          begin
            res := WAPTLocalJsonGet(Format('cancel_running_task.json?%s',[StrJoin('&',Args)]));
            if res.DataType<>stNull then
              writeln(utf8decode(format(rsCanceledTask, [res.S['description']])))
            else
              writeln(rsNoRunningTask);
          end
          else
          if (action='cancel-all') or (action='cancelall') then
          begin
            res := WAPTLocalJsonGet(Format('cancel_all_tasks.json?%s',[StrJoin('&',Args)]));
            if res.DataType<>stNull then
            begin
              for task in res do
                writeln(utf8decode(format(rsCanceledTask, [task.S['description']])))
            end
            else
              writeln(utf8decode(rsNoRunningTask));
          end
          else
          if action='update' then
          begin
            Logger('Call update URL...',DEBUG);
            res := WAPTLocalJsonGet(Format('update.json?%s',[StrJoin('&',Args)]));
            tasks.AsArray.Add(res);
            Logger(UTF8Encode('Task '+res.S['id']+' added to queue'),DEBUG);
          end
          else
          if action='audit' then
          begin
            Logger('Call audit URL...',DEBUG);
            res := WAPTLocalJsonGet(Format('audit.json?%s',[StrJoin('&',Args)]));
            WriteLn(utf8encode(res.S['message']));
            for task in res['content'] do
            begin
              tasks.AsArray.Add(task);
              Logger('Task '+task.S['id']+' added to queue',DEBUG);
            end;
          end
          else
          if action='register' then
          begin
            Logger('Call register URL...',DEBUG);
            res := WAPTLocalJsonGet(Format('register.json?%s',[StrJoin('&',Args)]),'admin','',-1,@HTTPLogin,3);
            tasks.AsArray.Add(res);
            Logger('Task '+res.S['id']+' added to queue',DEBUG);
          end
          else
          if (action='install') or (action='remove') or (action='forget') then
          begin
            if HasOption('only_if_not_process_running') then
              Args.Append('only_if_not_process_running='+GetOptionValue('only_if_not_process_running'));
            for package in sopackages do
            begin
              Logger('Call '+action+'?package='+package.AsString,DEBUG);
              Args.Append(utf8encode('package='+package.AsString));
              res := WAPTLocalJsonGet(Format(Action+'.json?%s',[StrJoin('&',Args)]),'admin','',-1,@HTTPLogin,3);
              if (action='install') or (action='forget')  then
              begin
                // single action
                if (res.AsObject=Nil) or not res.AsObject.Exists('id') then
                  WriteLn(utf8decode(format(rsErrorWithMessage, [res.AsString])))
                else
                  tasks.AsArray.Add(res);
              end
              else
              if (action='remove') then
              begin
                // list of actions..
                if (res.AsArray=Nil) then
                  WriteLn(utf8decode(format(rsErrorWithMessage, [res.AsString])))
                else
                for task in res do
                begin
                  tasks.AsArray.Add(task);
                  Logger('Task '+task.S['id']+' added to queue',DEBUG);
                end;
              end;
            end;
          end
          else if action='upgrade' then
          begin
            Logger('Call upgrade URL...',DEBUG);
            if HasOption('only_priorities') then
              Args.Append('only_priorities='+GetOptionValue('only_priorities'));
            if HasOption('only_if_not_process_running') then
              Args.Append('only_if_not_process_running='+GetOptionValue('only_if_not_process_running'));
            res := WAPTLocalJsonGet(Format('upgrade.json?%s',[StrJoin('&',args)]));
            Logger('Upgrade triggered...',DEBUG);
            if res.S['result']<>'OK' then
              WriteLn(utf8decode(format(rsErrorLaunchingUpgrade, [res.S['message']])))
            else
              for task in res['content'] do
              begin
                tasks.AsArray.Add(task);
                Logger('Task '+task.S['id']+' added to queue',DEBUG);
              end;
          end
          else
          if action='wuascan' then
          begin
            res := WAPTLocalJsonGet(Format('waptwua_scan?%s',[StrJoin('&',Args)]));
            tasks.AsArray.Add(res);
            Logger('Task '+res.S['id']+' added to queue',DEBUG);
          end
          else
          if action='wuadownload' then
          begin
            res := WAPTLocalJsonGet(Format('waptwua_download?%s',[StrJoin('&',Args)]));
            tasks.AsArray.Add(res);
            Logger('Task '+res.S['id']+' added to queue',DEBUG);
          end
          else
          if action='wuainstall' then
          begin
            res := WAPTLocalJsonGet(Format('waptwua_install?%s',[StrJoin('&',Args)]));
            tasks.AsArray.Add(res);
            Logger('Task '+res.S['id']+' added to queue',DEBUG);
          end;

          if (tasks<>Nil) and (tasks.AsArray.Length>0) then
          begin
            while ((remainingtasks=Nil) or (remainingtasks.AsArray.Length>0)) and not CheckEventsThread.Finished do
            try
              //if no message from service since more that 1 min, check if remaining tasks in queue...
              if (now-lastMessageTime>1*1/24/60) then
                raise Exception.create('Timeout waiting for events')
              else
              begin
                While CheckSynchronize(100) do;
                sleep(1000)
              end;
            except
              on E:Exception do
                begin
                  writeln(Format(rsCanceledTask,[E.Message]));
                  for task in tasks do
                    WAPTLocalJsonGet('cancel_task.json?id='+task.S['id']);
                end;
            end;
          end;

          while CheckSynchronize(1000) do;

        except
          localpassword := '';
          ExitCode:=3;
          raise;
        end;
      finally
        for task in tasks do
          WAPTLocalJsonGet('cancel_task.json?id='+task.S['id']);
      end;
    end
    else
    begin
      // Load main python application
      try
        MainModule:=TStringList.Create;
        MainModule.LoadFromFile(ExtractFilePath(ParamStr(0))+'wapt-get.py');
        PythonEngine.ExecStrings(MainModule);
      finally
        MainModule.Free;
      end;
    end;
  finally
    // stop program loop
    Terminate;
  end;
end;

constructor PWaptGet.Create(TheOwner: TComponent);
begin
  inherited Create(TheOwner);
  StopOnException:=True;
  InitializeCriticalSection(lock);

end;

destructor PWaptGet.Destroy;
begin
  Fwaptdevutils := Nil;
  if Assigned(CheckEventsThread) and (not CheckEventsThread.Suspended) then
    CheckEventsThread.Terminate;

  FreeAndNil(CheckEventsThread);

  if Assigned(FPythonEngine) then
    FPythonEngine.Free;
  DeleteCriticalSection(lock);
  {$ifdef windows}
  if HasOption('y','hide') then
    ShowWindow(GetConsoleWindow, SW_SHOWNORMAL or SW_RESTORE);
  {$endif}

  inherited Destroy;
end;

procedure PWaptGet.WriteHelp;
begin
  { add your help code here }
  writeln(utf8decode(format(rsUsage, [ExeName])));
  writeln(rsInstallOn);
end;

procedure PWaptGet.OnCheckEventsThreadNotify(Sender: TObject);
var
  Step,EventType:String;
  taskresult : ISuperObject;
  Events,Event,EventData:ISuperObject;

  //check if task with id id is in tasks list
  function isInTasksList(id:integer):boolean;
  var
    t:ISuperObject;
  begin
    //writeln('check '+IntToStr(id)+' in '+tasks.AsJSon());
    result := False;
    for t in tasks do
      if t.I['id'] = id then
      begin
        result := True;
        break;
      end;
  end;

  //remove task with id id from tasks list
  procedure removeTask(id:integer);
  var
    i:integer;
  begin
    for i:=0 to tasks.AsArray.Length-1 do
      if tasks.AsArray[i].I['id'] = id then
      begin
        tasks.AsArray.Delete(i);
        break;
      end;
  end;

begin
  EnterCriticalSection(lock);
  try
    lastMessageTime := Now;
    events := (Sender as TCheckEventsThread).Events;
    If Events <> Nil then
    begin
      for Event in Events do
      try
        EventType := Event.S['event_type'];
        EventData := Event['data'];
        if EventType.StartsWith('TASK_') then
        begin
          Step := EventType.Substring(5);
          taskresult := EventData;
          //Writeln(EventType,' ',taskresult.S['id'],' ',taskresult.S['summary']);
          if isInTasksList(taskresult.I['id']) then
          begin
            //writeln(taskresult.AsString);
            if (Step = 'START') then
              writeln(#13+UTF8Encode(taskresult.S['description']));
            if (Step = 'PROGRESS') then
              write(#13+utf8Encode(format(rsCompletionProgress,[taskresult.S['runstatus'], taskresult.D['progress']])+#13));
            if (Step = 'STATUS') then
              write(#13+utf8Encode(format(rsCompletionProgress,[taskresult.S['runstatus'], taskresult.D['progress']])+#13));
            //catch finish of task
            if (Step = 'FINISH') or (Step = 'ERROR') or (Step = 'CANCEL') then
            begin
              WriteLn(UTF8Encode(taskresult.S['summary']));
              if (Step = 'ERROR') or (Step = 'CANCEL') then
                ExitCode:=3;
              removeTask(taskresult.I['id']);
            end;
          end;
        end
        else if (EventType = 'PRINT') then
          Writeln(#13+UTF8Encode(EventData.AsString));
      except
        on E:Exception do WriteLn(#13+Format('Error listening to events: %s',[e.Message]));
      end;
    end
    else
      Write('.');
  finally
    LeaveCriticalSection(lock);
  end;
end;


function PWaptGet.remainingtasks: ISuperObject;
var
  task,pending,res:ISuperObject;
begin
  res := WAPTLocalJsonGet('tasks.json');
  if res<>Nil then
  begin
    pending := res['pending'];
    if res['running'] <> Nil then
      pending.AsArray.Add(res['running']);

    Result := TSuperObject.Create(stArray);
    if pending.AsArray.Length > 0 then
      for task in Self.tasks do
        if SOArrayFindFirst(task,pending,['id']) <> Nil then
          Result.AsArray.Add(task);
  end
  else
    Result := Nil;
end;

procedure PWaptGet.DoOnProgress(Sender: TObject);
begin
  if (GetTickCount-FLastProgressMs)  > 1000 then
  begin
    Write('.');
    FLastProgressMs := GetTickCount;
  end;
end;

procedure PWaptGet.DoOnHttpWork(ASender: TObject; AWorkMode: TWorkMode;
  AWorkCount: Int64);
begin
  if (GetTickCount-FLastProgressMs)  > 1000 then
  begin
    Write('.');
    FLastProgressMs := GetTickCount;
  end;
end;

function PWaptGet.CreateWaptAgent(BuildDir:String;Edition:String='waptagent'): String;
var
  Ini:TInifile;
begin
  try
    ini := TIniFile.Create(AppIniFilename('waptconsole'));
    Result := CreateWaptSetup(UTF8Encode(AuthorizedCertsDir),
      ini.ReadString('global', 'repo_url', ''),
      ini.ReadString('global', 'wapt_server', ''),
      BuildDir,
      'Wapt', @DoOnProgress,
      Edition,
      ini.ReadString('global', 'verify_cert', '0'),
      ini.ReadBool('global', 'use_kerberos', False ),
      FileExists(MakePath([WaptBaseDir,'waptenterprise','licencing.py'])),
      True,
      True,
      ini.ReadBool('global', 'use_fqdn_as_uuid',False),
      False,
      ini.ReadBool('global', 'use_ad_groups',False),
      ini.ReadBool('global', 'use_repo_rules',False),
      GetCmdParams('AppendHostProfiles',ini.ReadString('global', 'append_host_profiles','')),
      Nil,
      '',
      GetCmdParams('PrivateKeyPassword',''),
      GetCmdParams('Maturities',ini.ReadString('global', 'maturities', '')),
      GetCmdParams('WaptServiceAdminFilter',ini.ReadString('global','waptservice_admin_filter','False'))
      );
    Writeln('');
    Writeln('Built '+Result);
  finally
    ini.Free;
  end;
end;

function PWaptGet.CreateKeycert(commonname: String; basedir: String;
  keypassword: String; CodeSigning: Boolean; CA: Boolean; ClientAuth:Boolean=True;
  Overwrite:Boolean=False): String;
var
    keyfilename,
    crtbasename,
    country,
    locality,
    organization,
    orgunit,
    email,
    CACertFilename,
    CAKeyFilename,
    CAKeyPassword:String;
    PrintPwd: Boolean;

begin
  if basedir = '' then
    basedir:=GetCmdParams('BaseDir',ExtractFilePath(WaptPersonalCertificatePath));
  if basedir = '' then
    basedir:=AppendPathDelim(GetPersonalFolder)+'private';
  WriteLn('BaseDir: '+basedir);

  if not DirectoryExistsUTF8(basedir) then
    mkdir(basedir);

  keyfilename := AppendPathDelim(basedir)+commonname+'.pem';
  if commonname = '' then
  begin
    Write('Common name of certificate to create: ');
    readln(commonname);
  end;
  if commonname='' then
    Raise Exception.Create('No common name for certificate');

  if not Overwrite and FileExistsUTF8(AppendPathDelim(basedir)+commonname+'.crt') then
    Raise Exception.CreateFmt('Certificate %s already exists',[AppendPathDelim(basedir)+commonname+'.crt']);

  if not Overwrite and FileExistsUTF8(keyfilename) then
    Raise Exception.CreateFmt('Key %s already exists',[keyfilename]);

  printPwd := False;
  if not FindCmdLineSwitch('NoPrivateKeyPassword') then
  begin
    if GetCmdParams('PrivateKeyPassword64')<>'' then
      keypassword := DecodeStringBase64(GetCmdParams('PrivateKeyPassword64'));
    if keypassword='' then
      keypassword := GetCmdParams('PrivateKeyPassword','');

    if (keypassword='') and not FileExistsUTF8(keyfilename) then
    begin
      printPwd := True;
      keypassword := RandomPassword(12);
    end;

    if keypassword='' then
      keypassword := GetPrivateKeyPassword(keyfilename);
  end
  else
    keypassword := '';

  crtbasename := commonname;

  country := GetCmdParams('Country',Language);
  locality := GetCmdParams('Locality','');
  organization := GetCmdParams('Organization','');
  orgunit := GetCmdParams('OrgUnit','');
  email := GetCmdParams('Email','');

  CAKeyFilename := GetCmdParams('CAKeyFilename',WaptCAKeyFilename);
  CACertFilename := GetCmdParams('CACertFilename',WaptCACertFilename);
  if CAKeyFilename<>'' then
  begin
    if (CACertFilename<>'') and FileExistsUTF8(CACertFilename) then
      Writeln('Signed by: '+CACertFilename)
    else
      Raise Exception.Create('No CA Certificate to issue the new certificate');

    if not FindCmdLineSwitch('NoCAKeyPassword') then
      CAKeyPassword := GetCAKeyPassword(CAKeyFilename)
    else
      CAKeyPassword := '';
  end;

  result := CreateSignedCert(waptcrypto,
        keyfilename,
        crtbasename,
        basedir,
        country,
        locality,
        organization,
        orgunit,
        commonname,
        email,
        keypassword,
        CodeSigning,
        ClientAuth,
        CA,
        CACertFilename,
        CAKeyFilename,
        CAKeyPassword);

  WriteLn('Private Key Filename: '+keyfilename);
  WriteLn('Certificate Filename: '+Result);
  if PrintPwd then
    WriteLn('New private key password: '+keypassword);
end;


function PWaptGet.ScanLocalWaptrepo(RepoPath:String):Variant;
var
  LocalRepo:Variant;
begin
  LocalRepo := waptpackage.WaptLocalRepo(RepoPath);
  Result := LocalRepo.update_packages_index('--noarg--');
end;

function PWaptGet.BuildWaptUpgrade(PackageName,Version,BuildDir,SetupFilename: String): String;
var
  KeyPassword, SourcesDir, UpgradePackage,BuildResult,Certificate,PrivateKey: Variant;
begin
  // create waptupgrade package (after waptagent as we need the updated waptagent.sha1 file)
  BuildResult := Nil;
  if RightStr(buildDir,1) = '\' then
    buildDir := copy(buildDir,1,length(buildDir)-1);
  KeyPassword := GetPrivateKeyPassword;

  //BuildResult is a PackageEntry instance
  SourcesDir := PyUTF8Decode(BuildDir+'\waptupgrade');

  // we put new waptdeploy for automatisation of install
  ForceDirectoriesUTF8(MakePath([SourcesDir,'patchs']));
  CopyFile(makepath([WaptBaseDir,'waptdeploy.exe']),MakePath([SourcesDir,'patchs','waptdeploy.exe']));

  UpgradePackage := waptpackage.PackageEntry(waptfile := SourcesDir);
  UpgradePackage.package := PackageName;
  UpgradePackage.version := Version;

  BuildResult := UpgradePackage.build_package(target_directory := BuildDir);
  Certificate := waptcrypto.SSLCertificate(PyUTF8Decode(WaptPersonalCertificatePath));
  if VarPythonAsString(Certificate.is_code_signing)<>'True' then
      Raise Exception.CreateFmt('ERROR Personal Certificate is not a code signing certificate: %s',[WaptPersonalCertificatePath]);

  PrivateKey := Certificate.matching_key_in_dirs(private_key_password := KeyPassword);
  if VarIsNull(PrivateKey) or VarIsNone(PrivateKey) then
    Raise Exception.CreateFmt('ERROR No matching private key found with supplied password for : %s',[WaptPersonalCertificatePath]);

  UpgradePackage.sign_package(certificate := Certificate, private_key := PrivateKey);

  if not VarPyth.VarIsNone(BuildResult) and FileExistsUTF8(VarPythonAsString(BuildResult)) then
    Result := VarPythonAsString(BuildResult)
  else
    Result := '';
end;

procedure PWaptGet.UploadWaptAgentUpgrade(SetupFilename,WaptUpgradeFilename: String);
var
  Res:ISuperObject;
begin
  Writeln('Uploading '+SetupFilename+' to waptserver '+GetWaptServerURL);

  Res := WAPTServerJsonMultipartFilePost(
    GetWaptServerURL, 'upload_waptsetup', [], 'file', SetupFilename,
    WaptServerUser, WaptServerPassword, @DoOnHttpWork,GetWaptServerCertificateFilename);
  if Res.S['status'] = 'OK' then
    Writeln('OK')
  else
    raise Exception.CreateFmt('ERROR uploading %s: %s',[SetupFilename,Res.S['message']]);

  Writeln('Uploading '+WaptUpgradeFilename+' to waptserver '+GetWaptServerURL);

  Res := WAPTServerJsonMultipartFilePost(
    GetWaptServerURL, 'api/v3/upload_packages', [], ExtractFileName(WaptUpgradeFilename), WaptUpgradeFilename,
    WaptServerUser, WaptServerPassword, @DoOnHttpWork,GetWaptServerCertificateFilename);
  if Res.B['success'] then
    Writeln('OK : '+UTF8Encode(Res.S['msg']))
  else
    raise Exception.CreateFmt('ERROR uploading %s: %s',[WaptUpgradeFilename,Res.S['msg']]);

end;


function PWaptGet.Getwaptdevutils: Variant;
begin
  if not Assigned(PythonEngine) then
    Raise Exception.Create('No python engine available');
  if VarIsEmpty(Fwaptdevutils) or VarIsNull(Fwaptdevutils) then
    Fwaptdevutils:= VarPyth.Import('waptdevutils');
  Result := Fwaptdevutils;
end;

{$R *.res}

begin
  //IsAdmin;
  Application:=PWaptGet.Create(nil);
  Application.Title:='wapt-get';
  Application.Run;
  Application.Free;
end.

