program Test_Units_VCLstyles;

uses
  Vcl.Forms,
  Unit1 in 'Unit1.pas' {frmMain},
  VclStylePreview in '..\VclStylePreview.pas',
  VclStyleUtil in '..\VclStyleUtil.pas',
  Vcl.Themes,
  Vcl.Styles;

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;
end.
