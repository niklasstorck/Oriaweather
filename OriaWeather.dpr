program OriaWeather;

uses
  Vcl.Forms,
  Main in 'Main.pas' {MainForm},
  Setup in 'Setup.pas' {Setupform},
  Vcl.Themes,
  Vcl.Styles,
  InformationScreen in 'InformationScreen.pas' {Info};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.Title := 'Oriaweather';
  Application.CreateForm(TMainForm, MainForm);
  Application.CreateForm(TSetupForm, SetupForm);
  Application.CreateForm(TInfo, Info);
  Application.Run;

end.
