unit uvisconsolepostconf;

{$mode objfpc}{$H+}

interface

uses
  CommCtrl,
  PythonEngine, Classes, SysUtils, FileUtil, LazFileUtils, LazUTF8, IpHtml,
  Forms, Controls, Graphics, Dialogs, ComCtrls, StdCtrls, ExtCtrls, Buttons,
  ActnList, IdHTTP, IdComponent, LCLTranslator,
  LCLProc, EditBtn, Menus, uvisLoading;

type

  { TVisWAPTConsolePostConf }

  TVisWAPTConsolePostConf = class(TForm)
    ActCreateKey: TAction;
    ActCancel: TAction;
    ActCheckWaptHostname: TAction;
    ActCheckServerPassword: TAction;
    ActFindPrivateKey: TAction;
    ActCheckDNS: TAction;
    ActCreateKeys: TAction;
    ActBuildWaptAgent: TAction;
    ActUseExistingKey: TAction;
    ActNext: TAction;
    ActPrevious: TAction;
    ActionList1: TActionList;
    btn_check_wapt_server_password: TButton;
    btn_check_wapt_server_hostname: TButton;
    btn_check_wapt_server_ping: TButton;
    btn_find_private_key: TButton;
    ButCancel: TBitBtn;
    ButNext: TBitBtn;
    ButPrevious: TBitBtn;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    cbLaunchWaptConsoleOnExit: TCheckBox;
    cb_create_new_key_show_password: TCheckBox;
    cb_manual_wapt_server: TCheckBox;
    cb_use_existing_key_show_password: TCheckBox;
    cb_wapt_server_show_password: TCheckBox;
    EdWaptServerIP: TEdit;
    ed_create_new_key_key_name: TEdit;
    ed_create_new_key_password_1: TEdit;
    ed_create_new_key_password_2: TEdit;
    ed_create_new_key_private_directory: TDirectoryEdit;
    ed_existing_key_certificat_filename: TFileNameEdit;
    ed_existing_key_key_filename: TFileNameEdit;
    ed_existing_key_password: TEdit;
    ed_manual_repo_url: TEdit;
    EdWaptServerHostname: TEdit;
    ed_manual_wapt_server_url: TEdit;
    ed_package_prefix: TEdit;
    ed_wapt_server_password: TEdit;
    html_panel: TIpHtmlPanel;
    IdHTTP1: TIdHTTP;
    imagelist_check_status: TImageList;
    img_manual_repo_url: TImage;
    img_check_password: TImage;
    img_manual_wapt_server_url_status: TImage;
    LabWaptServerIP: TLabel;
    LbStep: TLabel;
    lbl_ed_create_new_key_directory: TLabel;
    lbl_ed_create_new_key_key_name: TLabel;
    lbl_ed_create_new_key_password_1: TLabel;
    lbl_ed_create_new_key_password_2: TLabel;
    lbl_ed_existing_key_cert_filename: TLabel;
    lbl_ed_existing_key_key_filename: TLabel;
    lbl_ed_existing_key_password: TLabel;
    lbl_ed_package_prefix: TLabel;
    lbl_manual_repo_url: TLabel;
    lbl_manual_wapt_server_url: TLabel;
    lbl_wapt_server_password: TLabel;
    lbl_wapt_server_hostname: TLabel;
    Panel3: TPanel;
    PanAgentTop: TPanel;
    pgkey_page_control: TPageControl;
    PagesControl: TPageControl;
    Panel1: TPanel;
    Panel15: TPanel;
    Panel_0_2: TPanel;
    ProgressBar1: TProgressBar;
    p_bottom: TPanel;
    Panel2: TPanel;
    Panel4: TPanel;
    panFinish: TPanel;
    pgBuildAgent: TTabSheet;
    pgFinish: TTabSheet;
    pgKey: TTabSheet;
    pgPackage: TTabSheet;
    pgParameters: TTabSheet;
    pg_agent_memo: TMemo;
    p_buttons: TPanel;
    p_right: TPanel;
    pgkey_ts_create_new_key: TTabSheet;
    pgkey_ts_use_existing_key: TTabSheet;
    rb_CreateKey: TRadioButton;
    rb_UseKey: TRadioButton;
    procedure ActBuildWaptAgentExecute(Sender: TObject);
    procedure ActCancelExecute(Sender: TObject);
    procedure ActCheckServerPasswordExecute(Sender: TObject);
    procedure ActCheckWaptHostnameExecute(Sender: TObject);
    procedure ActCheckWaptHostnameUpdate(Sender: TObject);
    procedure ActCreateKeysExecute(Sender: TObject);
    procedure ActCreateKeysUpdate(Sender: TObject);
    procedure ActFindPrivateKeyExecute(Sender: TObject);
    procedure ActFindPrivateKeyUpdate(Sender: TObject);
    procedure ActNextExecute(Sender: TObject);
    procedure ActNextUpdate(Sender: TObject);
    procedure ActPreviousExecute(Sender: TObject);
    procedure ActUseExistingKeyExecute(Sender: TObject);
    procedure btn_find_private_keyClick(Sender: TObject);
    procedure cb_manual_wapt_serverChange(Sender: TObject);
    procedure EdWaptServerHostnameKeyPress(Sender: TObject; var Key: char);
    procedure ed_create_new_key_key_nameKeyPress(Sender: TObject; var Key: char
      );
    procedure ed_create_new_key_password_1KeyPress(Sender: TObject;
      var Key: char);
    procedure ed_existing_key_passwordKeyPress(Sender: TObject; var Key: char);
    procedure ed_manual_repo_urlKeyPress(Sender: TObject; var Key: char);
    procedure ed_manual_wapt_server_urlKeyPress(Sender: TObject; var Key: char);
    procedure ed_package_prefixKeyPress(Sender: TObject; var Key: char);
    procedure ed_wapt_server_passwordKeyPress(Sender: TObject; var Key: char);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure html_panelHotClick(Sender: TObject);
    procedure IdHTTPWork(ASender: TObject; AWorkMode: TWorkMode; AWorkCount: Int64);
    procedure on_private_key_radiobutton_change( Sender : TObject );
    procedure on_show_password_change( Sender : TObject );
    procedure on_create_setup_waptagent_tick( Sender : TObject );
    procedure on_upload( ASender: TObject; AWorkMode: TWorkMode; AWorkCount: Int64 );
    procedure on_python_update(Sender: TObject; PSelf, Args: PPyObject; var Result: PPyObject);
    procedure on_accept_filename( Sender : TObject; var Value: String);
    procedure on_file_edit_button_click( Sender : TObject );
    procedure on_page_show( Sender : TObject );
    procedure async( data : PtrInt );
    procedure ActCheckDNSExecute(Sender: TObject);

  private
    m_skip_build_agent: boolean;
    m_has_waptservice_installed : boolean;
    m_language_offset : integer;

    CurrentVisLoading:TVisLoading;

    PackagesCertificateFilename:String;

    { private declarations }

    procedure SetButtonsEnable( enable : Boolean );
    procedure Clear();
    procedure LoadConfigIfExist();
    function ValidateWaptServer: boolean;
    procedure ValidatePageParameters( var bContinue : boolean );
    procedure ValidatePagePackageName( var bContinue : boolean );
    procedure ValidatePagePackageKey( var bContinue : boolean );
    procedure ValidatePageAgent( var bContinue : boolean );
    function  WriteConfig() : integer;
    procedure RegisterAndUpdate;
    function  RunCommands( const sl : TStrings ) : integer;
    procedure UpdateDocHTML();
  public
    procedure ShowValidationError( c : TControl; const msg : String );
  end;

var
  VisWAPTConsolePostConf: TVisWAPTConsolePostConf;

implementation

uses
  contnrs,
  VarPyth,
  dmwaptpython,
  uutil,
  uvalidation,
  udefault,
  LCLIntf,
  Windows,
  waptcommon,
  waptwinutils,
  tisinifiles,
  superobject,
  tiscommon,
  IniFiles,
  waptconsolepostconfres;

{$R *.lfm}

const
  ASYNC_ACTN_NEXT_EXECUTE : integer = 0;

{ TVisWAPTConsolePostConf }


procedure TVisWAPTConsolePostConf.FormCreate(Sender: TObject);
begin
  //preload_python(nil);
  ReadWaptConfig(WaptBaseDir+'wapt-get.ini');

  remove_page_control_border( self.PagesControl.Handle );
  remove_page_control_border( self.pgkey_page_control.Handle );

  self.PagesControl.ShowTabs := False;
  self.pgkey_page_control.ShowTabs := False;

  self.PagesControl.ActivePageIndex := 0;

  Clear();

  EdWAPTServerHostName.Text:= LowerCase(GetComputerName)+'.'+GetDNSDomain;
  LoadConfigIfExist();

  //if GetCmdParams('use-hostname',GetComputerName)

end;

procedure TVisWAPTConsolePostConf.FormShow(Sender: TObject);
begin
  EdWaptServerHostname.SetFocus;
  if VisLoading = Nil then
    VisLoading := TVisLoading.Create(Application);
  CurrentVisLoading := VisLoading;
end;

procedure TVisWAPTConsolePostConf.html_panelHotClick(Sender: TObject);
var
  url : String;
begin
  url := self.html_panel.HotURL;
  if 0 = Length(url) then
    exit;
  OpenURL( url );
end;

procedure TVisWAPTConsolePostConf.IdHTTPWork(ASender: TObject; AWorkMode: TWorkMode; AWorkCount: Int64);
begin
  if CurrentVisLoading<>Nil then
    CurrentVisLoading.DoProgress(ASender)
  else
  begin
    if ProgressBar1.Position>=ProgressBar1.Max then
      ProgressBar1.Position:=0
    else
      ProgressBar1.Position := ProgressBar1.Position+1;
    Application.ProcessMessages;
  end;
end;

procedure TVisWAPTConsolePostConf.on_private_key_radiobutton_change( Sender: TObject);
var
  b : boolean;
begin
  // Enable
  b := self.rb_CreateKey.Checked;
  self.lbl_ed_create_new_key_directory.Enabled      := b;
  self.lbl_ed_create_new_key_key_name.Enabled       := b;
  self.lbl_ed_create_new_key_password_1.Enabled     := b;
  self.lbl_ed_create_new_key_password_2.Enabled     := b;
  self.ed_create_new_key_private_directory.Enabled  := b;
  self.ed_create_new_key_key_name.Enabled           := b;
  self.ed_create_new_key_password_1.Enabled         := b;
  self.ed_create_new_key_password_2.Enabled         := b;
  self.cb_create_new_key_show_password.Enabled      := b;

  self.ed_create_new_key_private_directory.TabStop  := b;
  self.ed_create_new_key_key_name.TabStop           := b;
  self.ed_create_new_key_password_1.TabStop         := b;
  self.ed_create_new_key_password_2.TabStop         := b;


  b := not b;
  self.lbl_ed_existing_key_key_filename.Enabled     := b;
  self.lbl_ed_existing_key_cert_filename.Enabled    := b;
  self.lbl_ed_existing_key_password.Enabled         := b;
  self.ed_existing_key_key_filename.Enabled         := b;
  self.ed_existing_key_certificat_filename.Enabled  := b;
  self.ed_existing_key_password.Enabled             := b;
  self.cb_use_existing_key_show_password.Enabled    := b;

  self.ed_existing_key_key_filename.TabStop         := b;
  self.ed_existing_key_certificat_filename.TabStop  := b;
  self.ed_existing_key_password.TabStop             := b;


  // Focus
  if self.rb_CreateKey.Checked then
  begin
    self.pgkey_page_control.TabIndex := self.pgkey_ts_create_new_key.TabIndex ;

    if str_is_empty_when_trimmed(self.ed_create_new_key_password_2.Text) then
      set_focus_if_visible( self.ed_create_new_key_password_2 );

    if str_is_empty_when_trimmed(self.ed_create_new_key_password_1.Text) then
      set_focus_if_visible( self.ed_create_new_key_password_1 );

    if str_is_empty_when_trimmed(self.ed_create_new_key_key_name.Text) then
      set_focus_if_visible( self.ed_create_new_key_key_name );

    if str_is_empty_when_trimmed(self.ed_create_new_key_private_directory.Text) then
      set_focus_if_visible( self.ed_create_new_key_private_directory );
  end
  else
  begin
    self.pgkey_page_control.TabIndex := self.pgkey_ts_use_existing_key.TabIndex;

    if str_is_empty_when_trimmed(self.ed_existing_key_password.Text) then
      set_focus_if_visible( self.ed_existing_key_password );

    if str_is_empty_when_trimmed(self.ed_existing_key_certificat_filename.Text) then
      set_focus_if_visible( self.ed_existing_key_certificat_filename );

    if str_is_empty_when_trimmed(self.ed_existing_key_key_filename.Text) then
      set_focus_if_visible( self.ed_existing_key_key_filename );
  end;

end;

procedure TVisWAPTConsolePostConf.on_show_password_change( Sender: TObject);
var
  c : Char;
begin

  // Parameters
  if self.cb_wapt_server_show_password = Sender then
  begin
    if self.cb_wapt_server_show_password.Checked then
      c := #0
    else
      c := DEFAULT_PASSWORD_CHAR;
    self.ed_wapt_server_password.PasswordChar := c;
    exit;
  end;

  // Package create key
  if self.cb_create_new_key_show_password = Sender then
  begin
    if self.cb_create_new_key_show_password.Checked then
      c := #0
    else
      c := DEFAULT_PASSWORD_CHAR;
    self.ed_create_new_key_password_1.PasswordChar := c;
    self.ed_create_new_key_password_2.PasswordChar := c;
    exit;
  end;

  // Pacakge existing key
  if self.cb_use_existing_key_show_password = Sender then
  begin
    if self.cb_use_existing_key_show_password.Checked then
      c := #0
    else
      c := DEFAULT_PASSWORD_CHAR;
    self.ed_existing_key_password.PasswordChar := c;
    exit;
  end;

end;

procedure TVisWAPTConsolePostConf.on_create_setup_waptagent_tick(Sender: TObject );
var
  t : TRunReadPipeThread;
  sz : Real;
  max : Real;
  f : String;
begin
  if not Assigned(Sender) then
  begin
    Application.ProcessMessages;
    exit;
  end;

  t := TRunReadPipeThread(Sender);

  self.pg_agent_memo.Text:= t.Content;
  SendMessage(self.pg_agent_memo.Handle, EM_LINESCROLL, 0,self.pg_agent_memo.Lines.Count);

  f := IncludeTrailingPathDelimiter( GetTempDir(true) )+ 'waptagent.exe';
  if FileExists(f) then
  begin
    self.ProgressBar1.Position := FileSize(f);
  end;

  Application.ProcessMessages;
end;

procedure TVisWAPTConsolePostConf.on_upload(ASender: TObject; AWorkMode: TWorkMode; AWorkCount: Int64);
const
  WORK_FINISHED : integer = 62;
var
  l : integer;
  p : integer;
begin
  if self.pgBuildAgent = self.PagesControl.ActivePage then
  begin

    if WORK_FINISHED = AWorkCount then
    begin
      l := self.pg_agent_memo.Tag;
      self.pg_agent_memo.Lines[ l ] := Format( rs_upload_to_server, [100] );
      self.pg_agent_memo.Tag := 0;
      Application.ProcessMessages;
      exit;
    end;

    if self.pg_agent_memo.Tag = 0 then
    begin
      self.pg_agent_memo.Tag := self.pg_agent_memo.Lines.Count;
      self.pg_agent_memo.Append('');
      self.pg_agent_memo.Append('');
    end;
    l := self.pg_agent_memo.Tag;
    p := round(100 * AWorkCount / SETUP_AGENT_SIZE);
    self.pg_agent_memo.Lines[ l ] := Format( rs_upload_to_server, [p] );
    self.pg_agent_memo.Repaint;

    self.ProgressBar1.Position := SETUP_AGENT_SIZE + AWorkCount;
    Application.ProcessMessages;
  end;
end;

procedure TVisWAPTConsolePostConf.on_python_update(Sender: TObject; PSelf, Args: PPyObject; var Result: PPyObject);
begin
  Result:= DMPython.PythonEng.ReturnNone;
end;

procedure TVisWAPTConsolePostConf.on_accept_filename(Sender: TObject; var Value: String);
var
  r : integer;
  s : String;
begin
  if ed_existing_key_password.Text<>'' then
  try
    FindPrivateKey(ed_existing_key_certificat_filename.Text, ed_existing_key_password.Text );
  except
    exit;
  end
  else
    ed_existing_key_password.SetFocus;
end;

procedure TVisWAPTConsolePostConf.on_file_edit_button_click(Sender: TObject);
var
  s : String;
  paths : array[0..2] of String;
  i : integer;
begin

  //
  if self.ed_existing_key_key_filename = Sender then
  begin
    paths[0] := ExtractFileDir(self.ed_existing_key_certificat_filename.Text);
    paths[1] := ExtractFileDir(self.ed_existing_key_key_filename.Text);
    for i := 0 to Length(paths) - 1 do
    begin
      if DirectoryExists(paths[i]) then
      begin
        self.ed_existing_key_key_filename.InitialDir := paths[i];
        exit;
      end;
    end;
    exit;
  end;

  //
  if self.ed_existing_key_certificat_filename = Sender then
  begin
    paths[0] := ExtractFileDir(self.ed_existing_key_certificat_filename.Text);
    paths[1] := ExtractFileDir(self.ed_existing_key_key_filename.Text);
    for i := 0 to Length(paths) - 1 do
    begin
      if DirectoryExists( paths[i] ) then
      begin
        self.ed_existing_key_certificat_filename.InitialDir := paths[i];
        exit;
      end;
    end;
    exit;
  end;



end;

procedure TVisWAPTConsolePostConf.on_page_show(Sender: TObject);
var
  p : TTabSheet;
begin
  p := TTabSheet(Sender);;

  // Update doc html
  self.UpdateDocHTML();


  self.ActPrevious.Enabled  := true;
  self.ActNext.Enabled      := true;
  self.ActCancel.Enabled    := true;

  self.ActPrevious.Visible  := true;
  self.ActNext.Visible      := true;
  self.ActCancel.Visible    := true;


  if pgParameters = p then
  begin
    self.ActPrevious.Enabled := false;
    self.ActPrevious.Visible := false;
    set_focus_if_visible( self.EdWaptServerHostname );
  end

  else if pgPackage = p then
  begin
    set_focus_if_visible( self.ed_package_prefix );
  end

  else if pgKey = p then
  begin
    if (ed_existing_key_certificat_filename.Text<>'') and FileExists(ed_existing_key_certificat_filename.Text) then
    begin
      set_focus_if_visible( rb_UseKey );
      rb_UseKey.Checked:=True;
      if ed_existing_key_password.Text<>'' then
        ActFindPrivateKey.Execute
      else
        set_focus_if_visible( ed_existing_key_password );
    end
    else
    begin
      rb_CreateKey.Checked:=True;
      set_focus_if_visible( ed_create_new_key_key_name);
    end;
  end

  else if pgBuildAgent = p then
  begin
    Application.QueueAsyncCall( @async, PtrInt(ASYNC_ACTN_NEXT_EXECUTE) );
  end

  else if pgFinish = p then
  begin
    self.ActPrevious.Enabled := false;
    self.ActCancel.Enabled   := false;
    self.ActPrevious.Visible := false;
    self.ActCancel.Visible   := false;
    set_focus_if_visible( cbLaunchWaptConsoleOnExit );
  end;


end;

procedure TVisWAPTConsolePostConf.async( data: PtrInt );
var
  d : integer;
begin
  d := integer(data);
  if ASYNC_ACTN_NEXT_EXECUTE = d then
    ActNext.Execute;
end;



procedure TVisWAPTConsolePostConf.SetButtonsEnable(enable: Boolean);
begin
  self.ActPrevious.Enabled := enable;
  self.ActNext.Enabled     := enable;
  self.ActCancel.Enabled   := enable;
end;

procedure TVisWAPTConsolePostConf.Clear();
var
  r : integer;
begin

  SetButtonsEnable( true );

  self.m_skip_build_agent := false;

  r := srv_exist( m_has_waptservice_installed, WAPT_SERVICE_WAPTSERVICE );
  if r <> 0 then
    m_has_waptservice_installed := false;

  // pgParameters
  self.EdWaptServerHostname.Clear;
  self.cb_manual_wapt_server.Checked := false;
  self.ed_manual_repo_url.Clear;
  self.ed_manual_wapt_server_url.Clear;
  self.img_manual_repo_url.Picture.Clear;
  self.img_manual_wapt_server_url_status.Picture.Clear;
  self.ed_wapt_server_password.Clear;
  self.cb_wapt_server_show_password.Checked := false;
  self.on_show_password_change( self.cb_wapt_server_show_password );
  self.cb_manual_wapt_serverChange( self.cb_manual_wapt_server );


  // Private key and certificate
  self.ed_package_prefix.Clear;
  self.ed_create_new_key_private_directory.Clear;
  self.ed_create_new_key_key_name.Clear;
  self.ed_create_new_key_password_1.Clear;
  self.ed_create_new_key_password_2.Clear;
  self.ed_existing_key_key_filename.Clear;
  self.ed_existing_key_certificat_filename.Clear;
  self.ed_existing_key_password.Clear;

  self.ed_create_new_key_password_1.PasswordChar  := DEFAULT_PASSWORD_CHAR;
  self.ed_create_new_key_password_2.PasswordChar  := DEFAULT_PASSWORD_CHAR;
  self.ed_existing_key_password.PasswordChar      := DEFAULT_PASSWORD_CHAR;
  self.cb_create_new_key_show_password.Checked    := false;
  self.cb_use_existing_key_show_password.Checked  := false;

  self.ed_existing_key_key_filename.Filter := FILE_FILTER_PRIVATE_KEY;
  self.ed_existing_key_certificat_filename.Filter := FILE_FILTER_CERTIFICATE;

  self.ed_existing_key_key_filename.DialogOptions := self.ed_existing_key_key_filename.DialogOptions + [ofFileMustExist];
  self.ed_existing_key_certificat_filename.DialogOptions :=  self.ed_existing_key_certificat_filename.DialogOptions + [ofFileMustExist];

  self.rb_CreateKey.Checked := true;
  self.on_private_key_radiobutton_change( nil );
  self.on_show_password_change( self.cb_create_new_key_show_password  );
  self.on_show_password_change( self.cb_use_existing_key_show_password  );

  self.ed_package_prefix.Text:= DEFAULT_PACKAGE_PREFIX;
  self.ed_create_new_key_private_directory.Text := DEFAULT_PRIVATE_KEY_DIRECTORY;

  self.m_language_offset := offset_language();

  self.ActPrevious.Enabled := true;
  self.ActNext.Enabled     := true;
  self.ActCancel.Enabled   := true;

end;

procedure TVisWAPTConsolePostConf.LoadConfigIfExist();
var
  s       : String;
  i       : integer;
  r       : integer;
  configs : array of String;
  ini     : TIniFile;
begin
  ini := nil;

  SetLength( configs, 2 );
  configs[0] := INI_FILE_WAPTCONSOLE;
  configs[1] := INI_FILE_WAPTGET;

  for i := 0 to Length(configs) - 1 do
  begin
    if not FileExists( configs[i] ) then
      continue;
    ini := TIniFile.Create( configs[i] );

    self.ed_manual_wapt_server_url.Text := ini.ReadString( INI_GLOBAL, INI_WAPT_SERVER, self.ed_manual_wapt_server_url.Text );
    self.ed_manual_repo_url.Text        := ini.ReadString( INI_GLOBAL, INI_REPO_URL, self.ed_manual_repo_url.Text );
    self.ed_package_prefix.Text         := ini.ReadString( INI_GLOBAL, INI_DEFAULT_PACKAGE_PREFIX, self.ed_package_prefix.Text );
    self.EdWaptServerHostname.Text   := ini.ReadString( INI_GLOBAL, INI_WAPT_SERVER, self.EdWaptServerHostname.Text );
    r := url_hostname( s, self.ed_manual_wapt_server_url.Text );
    if r = 0 then
      self.EdWaptServerHostname.Text := s;

    self.ed_existing_key_certificat_filename.Text := ini.ReadString( INI_GLOBAL, INI_PERSONAL_CERTIFICATE_PATH, self.ed_existing_key_certificat_filename.Text );
    if Length( Trim(self.ed_existing_key_certificat_filename.Text) ) = 0 then
    begin
      self.rb_CreateKey.Checked := true;
      self.on_private_key_radiobutton_change( self.rb_CreateKey );
    end
    else
    begin
      self.ed_create_new_key_private_directory.Text := ExtractFilePath(self.ed_existing_key_certificat_filename.Text);
      self.rb_UseKey.Checked := true;
      self.on_private_key_radiobutton_change( self.rb_UseKey );
    end;

    ini.Free;
    ini := nil;
  end;

  if Assigned(ini) then
    ini.Free;

end;

function TVisWAPTConsolePostConf.ValidateWaptServer: boolean;
var
  i : integer;
  s : String;
  b : boolean;
  r : integer;
begin
  Result := false;

  self.imagelist_check_status.GetBitmap( CHECK_STATUS_PENDING, self.img_manual_wapt_server_url_status.Picture.Bitmap );
  self.imagelist_check_status.GetBitmap( CHECK_STATUS_PENDING, self.img_manual_repo_url.Picture.Bitmap );
  Application.ProcessMessages;

  if self.cb_manual_wapt_server.Checked then
  begin
    b := wapt_server_ping( self.ed_manual_wapt_server_url.Text );
    self.imagelist_check_status.GetBitmap( integer(not b), self.img_manual_wapt_server_url_status.Picture.Bitmap );
    Application.ProcessMessages;
    Result := b;

    b := wapt_server_is_repo_url(self.ed_manual_repo_url.Text );
    self.imagelist_check_status.GetBitmap( integer(not b), self.img_manual_repo_url.Picture.Bitmap );
    Application.ProcessMessages;
    Result := Result and b;
    exit;
  end;

  self.imagelist_check_status.GetBitmap( CHECK_STATUS_FAILED, self.img_manual_wapt_server_url_status.Picture.Bitmap );
  self.imagelist_check_status.GetBitmap( CHECK_STATUS_FAILED, self.img_manual_repo_url.Picture.Bitmap );
  r := url_hostname( s, self.EdWaptServerHostname.Text );
  if r <> 0 then
    exit;

  self.EdWaptServerHostname.Text := s;

  //
  self.ed_manual_wapt_server_url.Clear;
  for i := 0 to Length(WAPT_PROTOCOLS) - 1 do
  begin
    s := Format('%s://%s',  [WAPT_PROTOCOLS[i], self.EdWaptServerHostname.Text] );
    b := wapt_server_ping(s);
    if b then
    begin
      self.imagelist_check_status.GetBitmap( CHECK_STATUS_SUCCESS, self.img_manual_wapt_server_url_status.Picture.Bitmap );
      self.ed_manual_wapt_server_url.Text := s;
      break;
    end;
  end;
  Result := b;

  //
  self.ed_manual_repo_url.Clear;
  for i := 0 to Length(WAPT_PROTOCOLS) - 1 do
  begin
    s := Format( '%s://%s/wapt', [WAPT_PROTOCOLS[i], self.EdWaptServerHostname.Text] );
    b := wapt_server_is_repo_url( s );
    if b then
    begin
      self.imagelist_check_status.GetBitmap( CHECK_STATUS_SUCCESS, self.img_manual_repo_url.Picture.Bitmap );
      self.ed_manual_repo_url.Text := s;
      break;
    end;
  end;
  Result := Result and b;

end;

procedure TVisWAPTConsolePostConf.ActCheckWaptHostnameExecute(Sender: TObject);
var
  b : Boolean;
begin
  Screen.cursor := crHourGlass;
  try
    if ValidateWaptServer then
      if ed_wapt_server_password.text = '' then
        ed_wapt_server_password.SetFocus
      else
        ActCheckServerPassword.Execute;
  finally
    Screen.Cursor:=crDefault;
  end;
end;

procedure TVisWAPTConsolePostConf.ValidatePageParameters( var bContinue: boolean);
const
  VERSION_MINIMAL : String =   '1.7.3.3';
var
  v: String;
  r : integer;
  msg : String;
begin
  if not self.ValidateWaptServer then
    exit;

  bContinue := false;

  if not wizard_validate_waptserver_login( self, ed_wapt_server_password, ed_manual_wapt_server_url.Text, 'admin', ed_wapt_server_password.Text ) then
    exit;

  r := wapt_server_agent_version( v, self.ed_manual_wapt_server_url.Text , 'admin', self.ed_wapt_server_password.Text );
  if r = 0 then
  begin
    if CompareVersion( VERSION_MINIMAL, v ) > 0 then
    begin
      msg := Format( rs_you_wapt_agent_version_mismatch, [v] );
      self.ShowValidationError( self.ed_manual_wapt_server_url, msg );
      ShowMessage( rs_post_conf_will_now_exit );
      Close;
      exit;
    end;
  end;



  Application.ProcessMessages;
  bContinue := true;
end;

procedure TVisWAPTConsolePostConf.ValidatePagePackageName( var bContinue: boolean);
begin
  bContinue := false;

  if not wizard_validate_package_prefix( self, self.ed_package_prefix, self.ed_package_prefix.Text ) then
    exit;

  bContinue := true;
end;

procedure TVisWAPTConsolePostConf.ValidatePagePackageKey( var bContinue: boolean);
begin
  if not FileExistsUTF8(PackagesCertificateFilename) then
  begin
    ShowValidationError(ed_existing_key_certificat_filename,  Format(rs_certificate_filename_is_invalid,[PackagesCertificateFilename]) );
    bContinue := False;
    Exit;
  end;

  try
    ShowLoadWait(rsStoppingWaptservice,0,3);
    if m_has_waptservice_installed then
    try
      Application.ProcessMessages;
      Run('net stop waptservice');
    except
    end;

    ShowLoadWait(rsRegisteringComputer,1,3);
    WriteConfig;
    RegisterAndUpdate;

    ShowLoadWait(rsStartingWaptservice,2,3);
    if m_has_waptservice_installed then
    begin
      Application.ProcessMessages;
      Run('net start waptservice');
    end;
    ShowLoadWait(rsStartingWaptservice,3,3);
  finally
    HideLoadWait();
  end;
  bContinue := True
end;

procedure TVisWAPTConsolePostConf.ValidatePageAgent(var bContinue: boolean);
label
  LBL_FAIL;
var
  params_agent  : Tcreate_setup_waptagent_params;
  r             : integer;
  so            : ISuperObject;
  s             : String;
  pe            : TPythonEvent;
  params_package: Tcreate_package_waptupgrade_params;
begin
  bContinue := false;

  if not wizard_validate_waptserver_waptagent_is_not_present( self, nil, self.ed_manual_wapt_server_url.Text, r ) then
  begin
    if HTTP_RESPONSE_CODE_OK <> r then
      exit;
    r := MessageBox( 0, PChar(rs_wapt_agent_has_been_found_on_server_overwrite_agent), PChar(Application.Name), MB_ICONQUESTION or MB_YESNOCANCEL or MB_DEFBUTTON3 );
    if IDCANCEL = r then
      exit;
    self.m_skip_build_agent := IDNO = r;
    bContinue := true;
    Exit;
  end;

  self.ProgressBar1.Style := pbstNormal;
  self.ProgressBar1.Visible := true;
  self.pg_agent_memo.Clear;
  self.ProgressBar1.Position := 0;
  self.ProgressBar1.Max := SETUP_AGENT_SIZE * 3;
  Application.ProcessMessages;

  // Build agent
  create_setup_waptagent_params_init( @params_agent );

  params_agent.default_public_cert       := IniReadString( INI_FILE_WAPTCONSOLE, INI_GLOBAL, INI_PERSONAL_CERTIFICATE_PATH );
  params_agent.default_repo_url          := IniReadString( INI_FILE_WAPTCONSOLE, INI_GLOBAL, INI_REPO_URL );
  params_agent.default_wapt_server       := IniReadString( INI_FILE_WAPTCONSOLE, INI_GLOBAL, INI_WAPT_SERVER );
  params_agent.destination               := GetTempDir(true);
  params_agent.OnProgress                := @on_create_setup_waptagent_tick;

  r := create_setup_waptagent_params( @params_agent );
  if r <> 0 then
  begin
    self.ShowValidationError( self.pg_agent_memo,  rs_compilation_failed );
    goto LBL_FAIL;
  end;
  self.ProgressBar1.Position := SETUP_AGENT_SIZE;
  Application.ProcessMessages;


  // Upload agent
  try
    so := WAPTServerJsonMultipartFilePost(
      params_agent.default_wapt_server,
      'upload_waptsetup',
      [],
      'file',
      params_agent._agent_filename,
      'admin',
      self.ed_wapt_server_password.Text,
      @on_upload,
      ''
      );

    s := UTF8Encode( so.S['status'] );
    if s <> 'OK' then
    begin
      s := UTF8Encode( so.S['message'] );
      if Length(s) = 0 then
        s := UTF8Encode(so.AsJSon(false));
      Raise Exception.Create(s);
    end;
  except on Ex : Exception do
    begin
      self.ShowValidationError( nil, Ex.Message );
      self.ProgressBar1.Visible := false;
      exit;
    end;
  end;
  self.ProgressBar1.Position := SETUP_AGENT_SIZE * 2;

  // Build upload apt-upgrade
  if not wizard_validate_no_innosetup_process_running( self, nil ) then
    goto LBL_FAIL;

  pe :=  DMPython.PythonModuleDMWaptPython.Events.Items[1].OnExecute;
  DMPython.PythonModuleDMWaptPython.Events.Items[1].OnExecute := @on_python_update;


  params_package.server_username := 'admin';
  params_package.server_password := self.ed_wapt_server_password.Text;
  params_package.config_filename := INI_FILE_WAPTCONSOLE;
  params_package.dualsign        := false;
  if self.rb_CreateKey.Checked then
    params_package.private_key_password := self.ed_create_new_key_password_1.Text
  else
    params_package.private_key_password := self.ed_existing_key_password.Text;

  r := create_package_waptupgrade_params( @params_package );

  DMPython.PythonModuleDMWaptPython.Events.Items[1].OnExecute := pe;

  if r <> 0 then
  begin
    self.ShowValidationError( nil, params_package._err_message );
    goto LBL_FAIL;
  end;
  self.ProgressBar1.Position :=  SETUP_AGENT_SIZE * 3;
  Application.ProcessMessages;
  Sleep( 2 * 1000 );


  self.ProgressBar1.Visible := false;
  bContinue := true;
  exit;

LBL_FAIL:
  self.ProgressBar1.Visible := false;
end;

function TVisWAPTConsolePostConf.WriteConfig: integer;
var
   wapt_server : String;
   repo_url    : String;
   ini         : TIniFile;
   confs       : array of String;
   i           : integer;
   s           : String;
begin
  if 0 = Length(INI_FILE_WAPTCONSOLE) then
    exit(-1);
  if 0 = Length(INI_FILE_WAPTGET) then
    exit(-1);

  wapt_server := self.ed_manual_wapt_server_url.Text;
  repo_url    := wapt_server + '/wapt';

  SetLength( confs, 2 );
  confs[0] := INI_FILE_WAPTCONSOLE;
  confs[1] := INI_FILE_WAPTGET;

  for i:= 0 to Length(confs) -1  do
  begin
    result := -1;
    ini := TIniFile.Create( confs[i] );
    try
      ini.WriteString( INI_GLOBAL,        INI_DEFAULT_PACKAGE_PREFIX, self.ed_package_prefix.Text );
      ini.WriteString( INI_GLOBAL,        INI_PERSONAL_CERTIFICATE_PATH, PackagesCertificateFilename );
      ini.WriteString( INI_GLOBAL,        INI_WAPT_SERVER, wapt_server );
      ini.WriteString( INI_GLOBAL,        INI_REPO_URL, repo_url );
      ini.WriteString( INI_GLOBAL,        INI_CHECK_CERTIFICATES_VALIDITY, '0' );
      ini.WriteString( INI_GLOBAL,        INI_VERIFIY_CERT, '0' );
      ini.WriteString( INI_WAPTTEMPLATES, INI_REPO_URL, INI_WAPT_STORE_URL );
      ini.WriteString( INI_WAPTTEMPLATES, INI_VERIFIY_CERT, '1' );
      result := 0;
    finally
      ini.Free;
    end;
  end;

  // Copy certificate to
  s := IncludeTrailingPathDelimiter( WaptBaseDir ) + 'ssl' + PathDelim + ExtractFileName(PackagesCertificateFilename);
  if not FileUtil.CopyFile( PackagesCertificateFilename, s, false , false  ) then
    result := -1;

end;

procedure TVisWAPTConsolePostConf.RegisterAndUpdate;
var
   waptget,waptgetini : String;
   sl : TStringList;
   r : integer;
   wapt: Variant;
begin
  try
    Screen.Cursor:=crHourGlass;
    waptgetini:=IncludeTrailingPathDelimiter(WaptBaseDir) + 'wapt-get.ini';
    waptget := IncludeTrailingPathDelimiter(WaptBaseDir) + 'wapt-get.exe';
    wapt := DMPython.common.Wapt(config_filename := waptgetini);
    wapt.register_computer('--noarg--');
    wapt.update('--noarg--');
  finally
    Screen.Cursor:=crDefault;
  end;
end;

function TVisWAPTConsolePostConf.RunCommands(const sl: TStrings): integer;
var
  i : integer;
  m : integer;
  b : boolean;
begin
  m := sl.Count;

  self.ProgressBar1.Visible := true;
  self.ProgressBar1.Position:= 0;
  self.ProgressBar1.Max := m;
  Application.ProcessMessages;

  dec(m);

  for i := 0 to m do
  begin
    self.ProgressBar1.Position := i + 1;
    LbStep.Caption:=StringReplace(sl.Strings[i],self.ed_wapt_server_password.Text,'*****',[rfReplaceAll]);
    Application.ProcessMessages;
    try
      Run( UTF8Decode(sl.Strings[i]), '',   RUN_TIMEOUT_MS );
      result := 0;
    except on E : Exception do
      begin
        b := 1 = Integer(sl.Objects[i]);
        if b then
          continue;
        self.ShowValidationError( nil, e.Message );
        result := -1;
        break;
      end;
    end;
  end;
  LbStep.Caption:='Finished';
  self.ProgressBar1.Visible := false;
  Application.ProcessMessages;
end;

procedure TVisWAPTConsolePostConf.UpdateDocHTML();
label
  LBL_NO_DOC;
var
  p           : TTabSheet;
  str_index   : integer;
  buffer      : LPWSTR;
  r           : integer;
begin

  p := self.PagesControl.ActivePage;

  if pgParameters = p then
    str_index := 0
  else if pgPackage = p then
    str_index := 300
  else if pgKey = p then
    str_index := 200
  else if pgBuildAgent = p then
    str_index := 500
  else if pgFinish = p then
    str_index := 600
  else
    goto LBL_NO_DOC;


  buffer := nil;
  inc( str_index, self.m_language_offset );
  r := Windows.LoadStringW( HINSTANCE(), str_index, @buffer, 0 );

  if r < 1 then
    goto LBL_NO_DOC;

  html_panel.SetHtmlFromStr( buffer );
  exit;

LBL_NO_DOC:
  html_panel.SetHtmlFromStr( HTML_NO_DOC );
end;


procedure TVisWAPTConsolePostConf.ShowValidationError(c: TControl; const msg: String);
begin
  MessageDlg( self.Caption, msg,  mtError, [mbOK], 0 );
  if c is TWinControl and  TWinControl(c).Enabled then
    TWinControl(c).SetFocus;
end;

procedure TVisWAPTConsolePostConf.ActNextExecute(Sender: TObject);
label
  LBL_FAIL;
const
  ACT_PREV    : integer = 0;
  ACT_NEXT    : integer = 1;
  ACT_CANCEL  : integer = 2;
var
  act_states : array[0..2] of boolean;

  bContinue : Boolean;
  p         : TTabSheet;

  procedure push_states();
  begin
    push_cursor( crHourGlass );
    act_states[ACT_PREV]      := self.ActPrevious.Enabled;
    act_states[ACT_NEXT]      := self.ActNext.Enabled;
    act_states[ACT_CANCEL]    := self.ActCancel.Enabled;
    self.ActPrevious.Enabled  := false;
    self.ActNext.Enabled      := false;
    self.ActCancel.Enabled    := false;
  end;

  procedure pop_states();
  begin
    pop_cursor();
    self.ActPrevious.Enabled  := act_states[ACT_PREV];
    self.ActNext.Enabled      := act_states[ACT_NEXT];
    self.ActCancel.Enabled    := act_states[ACT_CANCEL];
  end;

begin
  bContinue := false;

  push_states();

  p := self.PagesControl.ActivePage;

  if pgParameters = p then
  begin
    self.ValidatePageParameters( bContinue );
    if not bContinue then
      goto LBL_FAIL;
  end

  else if pgPackage = p then
  begin
    self.ValidatePagePackageName( bContinue );
    if not bContinue then
      goto LBL_FAIL;
  end

  else if pgKey = p then
  begin
    self.ValidatePagePackageKey( bContinue );
    if not bContinue then
      goto LBL_FAIL;
  end

  else if pgBuildAgent = p then
  begin
    self.ValidatePageAgent(bContinue);
    if not bContinue then
      goto LBL_FAIL;
  end

  else if pgFinish = p then
  begin
    if cbLaunchWaptConsoleOnExit.Checked then
      launch_console();
    ExitProcess(0);
  end;

  pop_states();
  self.PagesControl.ActivePageIndex := self.PagesControl.ActivePageIndex + 1;
  exit;

LBL_FAIL:
  pop_states();
end;

procedure TVisWAPTConsolePostConf.ActCancelExecute(Sender: TObject);
var
  r : integer;
begin
  r := MessageDlg( rs_confirm, rs_confirm_cancel_post_config, mtConfirmation, mbYesNoCancel, 0);
  if mrYes = r then
    Close;
end;

procedure TVisWAPTConsolePostConf.ActBuildWaptAgentExecute(Sender: TObject);
var
  bContinue: Boolean;
begin
  ValidatePageAgent(bContinue);
end;

procedure TVisWAPTConsolePostConf.ActCheckServerPasswordExecute(Sender: TObject
  );
begin

  if not wizard_validate_waptserver_login( self, ed_wapt_server_password, ed_manual_wapt_server_url.Text, 'admin', ed_wapt_server_password.Text ) then
  begin
    ShowMessage(rs_a_problem_has_occured_while_trying_to_login_server);
    imagelist_check_status.GetBitmap(CHECK_STATUS_FAILED, img_check_password.Picture.Bitmap );
  end
  else
  begin
    imagelist_check_status.GetBitmap(CHECK_STATUS_SUCCESS, img_check_password.Picture.Bitmap );
    Application.ProcessMessages;
  end;

end;

procedure TVisWAPTConsolePostConf.ActCheckDNSExecute(Sender: TObject);
var
  cnames,ips : ISuperObject;
begin
  push_cursor( crHourGlass );

  ips := Nil;
  cnames := DNSCNAMEQuery(EdWaptServerHostname.Text);


  if (cnames<>Nil) and (cnames.AsArray.Length>0) then
    ips := DNSAQuery(cnames.AsArray[0].AsString)
  else
    ips := DNSAQuery(EdWaptServerHostname.Text);

  if (ips<>Nil) and (ips.AsArray.Length>0) then
  begin
    EdWaptServerHostname.SetFocus;
    EdWaptServerIP.text := ips.AsArray[0].AsString
  end
  else
  begin
    if Dialogs.MessageDlg(rsInvalidDNS,rsInvalidDNSfallback, mtConfirmation,mbYesNoCancel,0) = mrYes then
    begin
      EdWaptServerHostname.Text := GetLocalIP;
      EdWaptServerIP.Text:= GetLocalIP;
    end
    else
      EdWaptServerIP.text := '';
  end;

  if (EdWaptServerHostname.Text<>'') and (EdWaptServerIP.Text<>'')then
    ActCheckWaptHostname.Execute;

  pop_cursor();
end;


procedure TVisWAPTConsolePostConf.ActCheckWaptHostnameUpdate(Sender: TObject);
var
  b : boolean;
begin
  if self.cb_manual_wapt_server.Checked then
  begin
    b := 0 <> Length(Trim(self.ed_manual_wapt_server_url.Text));
    b := b or ( 0 <> Length(Trim(self.ed_manual_repo_url.Text)) );
  end
  else
    b := 0 <> Length(Trim(self.EdWaptServerHostname.Text));

  self.ActCheckWaptHostname.Enabled := b;
end;

procedure TVisWAPTConsolePostConf.ActCreateKeysExecute(Sender: TObject);
var
   r                      : integer;
   msg                    : String;
   s                      : String;
   params                 : TCreate_signed_cert_params;
begin
  if not DirectoryExists(self.ed_create_new_key_private_directory.Text) then
  begin
    msg := Format( rs_create_key_dir_not_exist, [self.ed_create_new_key_private_directory.Text] );
    r := MessageDlg( self.Name, msg,  mtConfirmation, mbYesNoCancel, 0 );
    if mrCancel = r then
      exit;
    if mrNo = r then
    begin
      self.ShowValidationError( self.ed_create_new_key_private_directory, rs_create_key_select_a_valide_private_key_directory );
      exit;
    end;

    if not CreateDir(self.ed_create_new_key_private_directory.Text ) then
    begin
      msg := Format( rs_create_key_dir_cannot_be_created, [self.ed_create_new_key_private_directory.Text] );
      self.ShowValidationError( self.ed_create_new_key_private_directory, msg );
      exit;
    end;
  end;

  if not wizard_validate_key_name( self, self.ed_create_new_key_key_name, self.ed_create_new_key_key_name.Text ) then
    exit;

  s := IncludeTrailingBackslash(self.ed_create_new_key_private_directory.Text) + self.ed_create_new_key_key_name.Text + '.pem';
  if FileExists(s) then
  begin
    self.ShowValidationError( self.ed_create_new_key_key_name, rs_create_key_a_key_with_this_name_exist );
    exit;
  end;

  s :=  IncludeTrailingBackslash(self.ed_create_new_key_private_directory.Text) + self.ed_create_new_key_key_name.Text + '.crt';
  if FileExists(s) then
  begin
    self.ShowValidationError( self.ed_create_new_key_key_name, rs_create_key_a_certificat_this_key_name_exist );
    exit;
  end;

  if not wizard_validate_str_password_are_not_empty_and_equals( self, self.ed_create_new_key_password_2, self.ed_create_new_key_password_1.Text, self.ed_create_new_key_password_2.Text ) then
    exit;

  if not wizard_validate_waptserver_waptagent_is_not_present( self, nil, self.ed_manual_wapt_server_url.Text, r  ) then
  begin
    if HTTP_RESPONSE_CODE_OK <> r then
      exit;
    r := MessageDlg( Application.Name, rs_wapt_agent_has_been_found_on_server_confirm_create_package_key, mtConfirmation, mbYesNoCancel, 0 );
    if r in [mrCancel,mrNo] then
      exit;

  end;

  create_signed_cert_params_init( @params );
  params.destdir      := ExcludeTrailingPathDelimiter(self.ed_create_new_key_private_directory.Text);
  params.keypassword  := self.ed_create_new_key_password_1.Text;
  params.keyfilename  := IncludeTrailingPathDelimiter(self.ed_create_new_key_private_directory.Text) + self.ed_create_new_key_key_name.Text + '.' + EXTENSION_PRIVATE_KEY;
  params.commonname   := self.ed_manual_wapt_server_url.Text;

  r := create_signed_cert_params( @params );
  if r <> 0 then
  begin
    self.ShowValidationError( nil, params._error_message );
    exit;
  end;
end;

procedure TVisWAPTConsolePostConf.ActCreateKeysUpdate(Sender: TObject);
begin
  ActCreateKeys.Enabled:=(ed_create_new_key_key_name.Text<>'') and (ed_create_new_key_password_1.Text<>'') and
      (ed_create_new_key_password_1.Text = ed_create_new_key_password_2.Text) and
        not FileExistsUTF8(AppendPathDelim(ed_create_new_key_private_directory.Text) + ed_create_new_key_key_name.Text+'.pem');
end;

procedure TVisWAPTConsolePostConf.ActFindPrivateKeyExecute(Sender: TObject);
begin
  try
    Screen.Cursor:=crHourGlass;
    try
      ed_existing_key_key_filename.Text := FindPrivateKey(ed_existing_key_certificat_filename.Text, ed_existing_key_password.Text );
      PackagesCertificateFilename := ed_existing_key_certificat_filename.Text;
    except
      MessageDlg(Application.Name, rs_no_matching_key, mtInformation, [mbOK], 0 );
      exit;
    end;
  finally
    Screen.Cursor:=crDefault;
  end;
end;

procedure TVisWAPTConsolePostConf.ActFindPrivateKeyUpdate(Sender: TObject);
begin
  ActFindPrivateKey.Enabled:= (ed_existing_key_certificat_filename.Text<>'') and FileExists(ed_existing_key_certificat_filename.Text) and (ed_existing_key_password.Text<>'');
end;

procedure TVisWAPTConsolePostConf.ActNextUpdate(Sender: TObject);
var
  ts : TTabSheet;
begin
  ts := self.PagesControl.Pages[ self.PagesControl.PageIndex ];

  if pgParameters = ts then
  begin
    ActPrevious.Enabled := false;
    exit;
  end;

  if pgFinish = ts then
  begin
    ActPrevious.Enabled := false;
    ActNext.Caption:= rs_finished;
    exit;
  end;
end;

procedure TVisWAPTConsolePostConf.ActPreviousExecute(Sender: TObject);
var
  p : TTabSheet;
begin
  p := self.PagesControl.ActivePage;
  if pgFinish = p then
  begin
    self.PagesControl.ActivePageIndex := pgKey.TabIndex;
  end
  else
    PagesControl.ActivePageIndex := PagesControl.ActivePageIndex - 1;
end;

procedure TVisWAPTConsolePostConf.ActUseExistingKeyExecute(Sender: TObject);
var
   r                      : integer;
   msg                    : String;
   s                      : String;
   params                 : TCreate_signed_cert_params;
   package_certificate    : String;
begin
  if str_is_empty_when_trimmed(self.ed_existing_key_key_filename.Text) then
  begin
    self.ShowValidationError( self.ed_existing_key_key_filename, rs_key_filename_cannot_be_empty );
    exit;
  end;
  if str_is_empty_when_trimmed(self.ed_existing_key_certificat_filename.Text) then
  begin
    self.ShowValidationError( self.ed_existing_key_certificat_filename, rs_certificate_filename_cannot_be_empty );
    exit;
  end;

  if not FileExists(self.ed_existing_key_key_filename.Text) then
  begin
    msg := Format( rs_key_filename_is_invalid, [self.ed_existing_key_key_filename.Text] );
    self.ShowValidationError( self.ed_existing_key_key_filename, msg );
    exit;
  end;

  if not FileExists(self.ed_existing_key_certificat_filename.Text) then
  begin
    msg := Format( rs_certificate_filename_is_invalid, [self.ed_existing_key_certificat_filename] );
    self.ShowValidationError( self.ed_existing_key_certificat_filename, msg );
    exit;
  end;

  if not wizard_validate_key_password( self, self.ed_existing_key_password, self.ed_existing_key_key_filename.Text, self.ed_existing_key_password.Text ) then
    exit;

  PackagesCertificateFilename := ed_existing_key_certificat_filename.Text;
end;

procedure TVisWAPTConsolePostConf.btn_find_private_keyClick(Sender: TObject);
begin
  if ed_existing_key_password.Text = '' then
  begin
    MessageDlg( Application.Name, rs_no_key_password, mtError, [mbOK], 0 );
    ed_existing_key_password.SetFocus;
    Exit;
  end;

  try
    Screen.Cursor:=crHourGlass;
    try
      ed_existing_key_key_filename.Text := FindPrivateKey(ed_existing_key_certificat_filename.Text, ed_existing_key_password.Text );
    except
      MessageDlg(Application.Name, rs_no_matching_key, mtInformation, [mbOK], 0 );
      exit;
    end;
  finally
    Screen.Cursor:=crDefault;
  end;
end;

procedure TVisWAPTConsolePostConf.cb_manual_wapt_serverChange(Sender: TObject);
var
  b :boolean;
begin
  b := self.cb_manual_wapt_server.Checked;

  self.lbl_manual_repo_url.Enabled        := b;
  self.lbl_manual_wapt_server_url.Enabled := b;
  self.ed_manual_wapt_server_url.Enabled  := b;
  self.ed_manual_repo_url.Enabled         := b;

  self.ed_manual_wapt_server_url.TabStop  := b;
  self.ed_manual_repo_url.TabStop         := b;

  if b then
    set_focus_if_visible( self.ed_manual_wapt_server_url );

  b := not b;
  self.lbl_wapt_server_hostname.Enabled   := b;
  self.EdWaptServerHostname.Enabled    := b;
  self.EdWaptServerHostname.TabStop    := b;

  if b then
    set_focus_if_visible( self.EdWaptServerHostname );

  self.img_manual_repo_url.Picture.Clear;
  self.img_manual_wapt_server_url_status.Picture.Clear;

end;

procedure TVisWAPTConsolePostConf.EdWaptServerHostnameKeyPress(Sender: TObject;
  var Key: char);
begin
  if EdWaptServerHostname.Text = '' then
      EdWAPTServerHostName.Text:= LowerCase(GetComputerName)+'.'+GetDNSDomain;

  if Integer(Key) = VK_RETURN then
    ActCheckDNS.Execute;

end;

procedure TVisWAPTConsolePostConf.ed_create_new_key_key_nameKeyPress(
  Sender: TObject; var Key: char);
begin
  if (Key=#13) and (ed_create_new_key_key_name.text<>'') then
    ed_create_new_key_password_1.SetFocus;

end;

procedure TVisWAPTConsolePostConf.ed_create_new_key_password_1KeyPress(
  Sender: TObject; var Key: char);
begin
  if (Key=#13) and (ed_create_new_key_password_1.text<>'') then
    ed_create_new_key_password_2.SetFocus;

end;

procedure TVisWAPTConsolePostConf.ed_existing_key_passwordKeyPress(
  Sender: TObject; var Key: char);
begin
  If Key=#13 then
  begin
    ed_existing_key_password.SelectAll;
    ActFindPrivateKey.Execute;
    ActUseExistingKey.Execute;
  end;
end;


procedure TVisWAPTConsolePostConf.ed_manual_repo_urlKeyPress(Sender: TObject; var Key: char);
begin
  self.img_manual_repo_url.Picture.Clear;
  self.OnKeyPress( Sender, Key );
end;

procedure TVisWAPTConsolePostConf.ed_manual_wapt_server_urlKeyPress( Sender: TObject; var Key: char);
begin
  self.img_manual_wapt_server_url_status.Picture.Clear;
  self.OnKeyPress( Sender, Key );
end;

procedure TVisWAPTConsolePostConf.ed_package_prefixKeyPress(Sender: TObject;
  var Key: char);
begin
  if (key=#13) and (trim(ed_package_prefix.Text)<>'') then
  begin
    ed_package_prefix.Text := trim(ed_package_prefix.Text);
    ActNext.Execute;
  end;
end;

procedure TVisWAPTConsolePostConf.ed_wapt_server_passwordKeyPress(
  Sender: TObject; var Key: char);
begin
  If key = #13 then
  begin
    ed_wapt_server_password.SelectAll;
    ActCheckServerPassword.Execute;
  end;
end;


end.

