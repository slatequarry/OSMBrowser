program OSMBrowser;

uses
  Vcl.Forms,
  uOSMBrowser in 'uOSMBrowser.pas' {frmOSMbrowser},
  uOSM in 'uOSM.pas',
  uConfigDialog in 'uConfigDialog.pas' {frmConfig},
  Vcl.Themes,
  Vcl.Styles;

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.Title := 'OSM Browser';
  TStyleManager.TrySetStyle('Aqua Light Slate');
  Application.CreateForm(TfrmOSMbrowser, frmOSMbrowser);
  Application.Run;
end.
