program OSMBrowser;

uses
  Vcl.Forms,
  uOSMBrowser in 'uOSMBrowser.pas' {frmOSMbrowser},
  uOSM in 'uOSM.pas',
  uConfigDialog in 'uConfigDialog.pas' {frmConfig};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmOSMbrowser, frmOSMbrowser);
  Application.Run;
end.
