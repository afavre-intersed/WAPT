unit uvistriggerhostsaction;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  Interfaces, ActnList, ExtCtrls, Buttons, sogrid, superobject, VirtualTrees,
  DefaultTranslator, ImgList, syncobjs;

type

  { TVisTriggerHostsAction }

  TVisTriggerHostsAction = class(TForm)
    ActStop: TAction;
    ActUpgrade: TAction;
    ActionList1: TActionList;
    BitBtn2: TBitBtn;
    Button1: TButton;
    Button5: TButton;
    ImageList1: TImageList;
    Panel4: TPanel;
    ProgressGrid: TSOGrid;
    procedure ActStopExecute(Sender: TObject);
    procedure ActUpgradeExecute(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure ProgressGridDragAllowed(Sender: TBaseVirtualTree;
      Node: PVirtualNode; Column: TColumnIndex; var Allowed: Boolean);
    procedure ProgressGridGetImageIndexEx(Sender: TBaseVirtualTree;
      Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex;
      var Ghosted: Boolean; var ImageIndex: Integer;
      var ImageList: TCustomImageList);
    procedure ProgressGridGetText(Sender: TBaseVirtualTree; Node: PVirtualNode;
      RowData, CellData: ISuperObject; Column: TColumnIndex;
      TextType: TVSTTextType; var CellText: string);
    procedure ProgressGridInitNode(Sender: TBaseVirtualTree; ParentNode,
      Node: PVirtualNode; var InitialStates: TVirtualNodeInitStates);
    procedure ProgressGridMeasureItem(Sender: TBaseVirtualTree;
      TargetCanvas: TCanvas; Node: PVirtualNode; var NodeHeight: Integer);
  private
    Faction: String;
    Fhosts: ISuperObject;
    Fnotifyserver: Boolean;
    Stopped : Boolean;
    gridLock : TCriticalSection;
    procedure Setaction(AValue: String);
    procedure Sethosts(AValue: ISuperObject);
    { private declarations }
  public
    { public declarations }
    property notifyServer:Boolean read Fnotifyserver write FNotifyServer;
    property action:String read Faction write Setaction;
    property hosts:ISuperObject read Fhosts write Sethosts;
  end;

var
  VisTriggerHostsAction: TVisTriggerHostsAction;

implementation

{$R *.lfm}
uses tiscommon,waptcommon,IdHTTP,UScaleDPI,dmwaptpython,VarPyth;

{ TVisTriggerHostsAction }

procedure TVisTriggerHostsAction.ActUpgradeExecute(Sender: TObject);
var
  SOAction, SOActions,res,host:ISuperObject;
  actions_json:Variant;
  signed_actions_json:String;
  waptdevutils: Variant;
  VPrivateKeyPassword: Variant;
begin
  Stopped := False;

  for host in ProgressGrid.Data do
  begin
    if uppercase(host.S['status'])<>'OK' then
    begin
      host.S['status'] := '';
      host.S['message'] := '';
    end;
  end;
  ProgressGrid.Refresh;

  waptdevutils := Import('waptdevutils');

  for host in ProgressGrid.Data do
  try
    Screen.Cursor:=crHourGlass;
    if Stopped then Break;
    if uppercase(host.S['status']) = 'OK' then
      Continue;
    if host.S['reachable'] <> 'OK' then
    begin
       host.S['status'] := 'SKIPPED';
       host.S['message'] := 'Not connected';
       Continue;
    end;

    host.S['status'] := 'STARTED';
    ProgressGrid.InvalidateFordata(host);
    Application.ProcessMessages;
    try
      SOAction := SO();
      SOAction.S['action'] := action;
      SOAction.S['uuid'] := host.S['uuid'];
      if Fnotifyserver then
        SOAction.I['notify_server'] := 1;
      SOActions := TSuperObject.Create(stArray);
      SOActions.AsArray.Add(SOAction);

      //transfer actions as json string to python
      actions_json := SOActions.AsString;

      VPrivateKeyPassword := PyUTF8Decode(dmpython.privateKeyPassword);

      signed_actions_json := VarPythonAsString(waptdevutils.sign_actions(
          actions:=actions_json,
          sign_certs := DMPython.WAPT.personal_certificate('--noarg--'),
          sign_key := DMPython.WAPT.private_key(private_key_password := VPrivateKeyPassword)));

      SOActions := SO(signed_actions_json);

      res := WAPTServerJsonPost('/api/v3/trigger_host_action?uuid=%S&timeout=%D',[host.S['uuid'],waptservice_timeout],SOActions);
      // new behaviour
      if (res<>Nil) and res.AsObject.Exists('success') then
      begin
        if res.AsObject.Exists('msg') then
          host['message'] := res['msg'];
        if  res.B['success'] then
          host.S['status'] := 'OK'
        else
          host.S['status'] := 'ERROR';
      end
      else
        host.S['status'] := 'BAD ANSWER';
      ProgressGrid.InvalidateFordata(host);
      Application.ProcessMessages;
    except
      on E:Exception do
      begin
        host.S['status'] := 'ERROR';
        host.S['message'] := host.S['message']+' '+UTF8Decode(e.Message);
        ProgressGrid.InvalidateFordata(host);
        Application.ProcessMessages;
      end;
    end;

  finally
    Screen.Cursor:=crdefault;
  end;
end;

procedure TVisTriggerHostsAction.FormCreate(Sender: TObject);
begin
  ScaleDPI(Self,96); // 96 is the DPI you designed
  ScaleImageList(ImageList1,96);
  Action := 'upgrade_host';
  notifyServer:=True;
end;

procedure TVisTriggerHostsAction.ProgressGridDragAllowed(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex; var Allowed: Boolean);
begin
  If Column=0 then Allowed:=False;
end;

procedure TVisTriggerHostsAction.ProgressGridGetImageIndexEx(
  Sender: TBaseVirtualTree; Node: PVirtualNode; Kind: TVTImageKind;
  Column: TColumnIndex; var Ghosted: Boolean; var ImageIndex: Integer;
  var ImageList: TCustomImageList);
var
  RowSO, update_status: ISuperObject;
begin
  if Column=0 then
  begin
    RowSO := ProgressGrid.GetNodeSOData(Node);
    if RowSO <> nil then
    begin
      ImageList := ImageList1;
      update_status := RowSO['status'];
      if (update_status <> nil) then
      begin
        if (update_status.AsString = 'OK') then
          ImageIndex := 0
        else
        if (update_status.AsString = 'ERROR') then
          ImageIndex := 2
        else
          ImageIndex := -1;
      end;
    end;
  end
end;

procedure TVisTriggerHostsAction.ProgressGridGetText(Sender: TBaseVirtualTree;
  Node: PVirtualNode; RowData, CellData: ISuperObject; Column: TColumnIndex;
  TextType: TVSTTextType; var CellText: string);
begin
  if Column=0 then
    CellText:='';
end;

procedure TVisTriggerHostsAction.ProgressGridInitNode(Sender: TBaseVirtualTree;
  ParentNode, Node: PVirtualNode; var InitialStates: TVirtualNodeInitStates);
begin
  InitialStates := InitialStates + [ivsMultiline];
end;

procedure TVisTriggerHostsAction.ProgressGridMeasureItem(Sender: TBaseVirtualTree;
  TargetCanvas: TCanvas; Node: PVirtualNode; var NodeHeight: Integer);
begin
{  if Sender.MultiLine[Node] then
    NodeHeight := ProgressGrid.ComputeNodeHeight(TargetCanvas, Node, 4,'X');
  if NodeHeight < ProgressGrid.DefaultNodeHeight then
    NodeHeight:=ProgressGrid.DefaultNodeHeight;}
end;

procedure TVisTriggerHostsAction.ActStopExecute(Sender: TObject);
begin
  Stopped := True;
end;

procedure TVisTriggerHostsAction.Sethosts(AValue: ISuperObject);
var
  data : ISuperObject;
begin
  if Fhosts=AValue then Exit;
  FHosts := AValue;
  if FHosts<>Nil then
    data := FHosts.Clone
  else
    data := Nil;
  ProgressGrid.Data := data;
end;

procedure TVisTriggerHostsAction.Setaction(AValue: String);
begin
  if Faction=AValue then Exit;
  Faction:=AValue;
end;

end.
