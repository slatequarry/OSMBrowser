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
    BitBtn1: TBitBtn;
    GroupBox1: TGroupBox;
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
  private
    { Private-Deklarationen }
  public
    { Public-Deklarationen }
    class function ShowDialog(AppStorage :TJvCustomAppStorage) :boolean;
  end;

implementation

{$R *.dfm}

class function TfrmConfig.ShowDialog(AppStorage :TJvCustomAppStorage) :boolean;
var frmConfig: TfrmConfig;
begin
  frmConfig:=TfrmConfig.Create(Application);
  try
    frmConfig.chkBasicAuth.Checked:=AppStorage.ReadBoolean('Proxy\BasicAuth',false);
    frmConfig.edtServer.Text:=AppStorage.ReadString('Proxy\Server','');
    frmConfig.edtPort.Value:=AppStorage.ReadInteger('Proxy\Port',0);
    frmConfig.edtUser.Text:=AppStorage.ReadString('Proxy\User','');
    frmConfig.edtPassword.Text:=AppStorage.ReadString('Proxy\Password','');
    result:=frmConfig.ShowModal=mrOk;
    if result then begin
      AppStorage.WriteBoolean('Proxy\BasicAuth',frmConfig.chkBasicAuth.Checked);
      AppStorage.WriteString('Proxy\Server',frmConfig.edtServer.Text);
      AppStorage.WriteInteger('Proxy\Port',round(frmConfig.edtPort.Value));
      AppStorage.WriteString('Proxy\User',frmConfig.edtUser.Text);
      AppStorage.WriteString('Proxy\Password',frmConfig.edtPassword.Text);
    end;
  finally
    FreeAndNil(frmConfig);
  end;
end;

end.
