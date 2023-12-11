program Oriaweather;



{$R *.dres}

uses
  Vcl.Forms,
  Main in 'Main.pas' {Mainform},
  Setup in 'Setup.pas',
  WUnit in 'WUnit.pas',
  InformationScreen in 'InformationScreen.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainform, Mainform);
  Application.CreateForm(TSetupform, Setupform);
  Application.CreateForm(TInfo, Info);
  Application.Run;
end.
