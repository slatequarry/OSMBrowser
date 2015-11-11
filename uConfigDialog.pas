unit uConfigDialog;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Buttons, Vcl.ExtCtrls,
  JvAppStorage, Vcl.Mask, JvExMask, JvSpin;

type
  TfrmConfig = class(TForm)
    pnlButtons: TPanel;
    btnOk: TBitBtn;
    btnCancel: TBitBtn;
    boxProxy: TGroupBox;
    chkBasicAuth: TCheckBox;
    Label1: TLabel;
    edtServer: TEdit;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    edtUser: TEdit;
    Label5: TLabel;
    edtPassword: TEdit;
    edtPort: TJvSpinEdit;
    boxStart: TGroupBox;
    edtStartsearch: TEdit;
    lblStartsearch: TLabel;
    edtZoom: TJvSpinEdit;
    lblZoom: TLabel;
    boxTileUrl: TGroupBox;
    cbbTileUrl: TComboBox;
    Label6: TLabel;
  private
    { Private-Deklarationen }
  public
    { Public-Deklarationen }
    class function ShowDialog(AppStorage :TJvCustomAppStorage; Cancel :boolean = true) :boolean;
  end;

implementation

{$R *.dfm}

class function TfrmConfig.ShowDialog(AppStorage :TJvCustomAppStorage; Cancel :boolean = true) :boolean;
var frmConfig: TfrmConfig;
begin
  frmConfig:=TfrmConfig.Create(Application);
  try
    with frmConfig do begin
      btnCancel.Enabled:=Cancel;

      cbbTileUrl.ItemIndex:=
        cbbTileUrl.Items.IndexOf(AppStorage.ReadString('Server\TileUrl',cbbTileUrl.Items[0]));
      edtStartsearch.Text:=AppStorage.ReadString('Start\Search','Saalfeld');
      edtZoom.Value:=AppStorage.ReadInteger('Start\Zoom',14);
      chkBasicAuth.Checked:=AppStorage.ReadBoolean('Proxy\BasicAuth',false);
      edtServer.Text:=AppStorage.ReadString('Proxy\Server','');
      edtPort.Value:=AppStorage.ReadInteger('Proxy\Port',0);
      edtUser.Text:=AppStorage.ReadString('Proxy\User','');
      edtPassword.Text:=AppStorage.ReadString('Proxy\Password','');

      result:=ShowModal=mrOk;

      if result then begin
        AppStorage.WriteString('Server\TileUrl',cbbTileUrl.Text);
        AppStorage.WriteString('Start\Search',edtStartsearch.Text);
        AppStorage.WriteInteger('Start\Zoom',round(edtZoom.Value));
        AppStorage.WriteBoolean('Proxy\BasicAuth',chkBasicAuth.Checked);
        AppStorage.WriteString('Proxy\Server',edtServer.Text);
        AppStorage.WriteInteger('Proxy\Port',round(edtPort.Value));
        AppStorage.WriteString('Proxy\User',edtUser.Text);
        AppStorage.WriteString('Proxy\Password',edtPassword.Text);
      end;
    end;
  finally
    FreeAndNil(frmConfig);
  end;
end;

end.
