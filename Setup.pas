unit Setup;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtDlgs, Vcl.StdCtrls, Vcl.ExtCtrls,
  Vcl.Buttons;

type
  TSetupForm = class(TForm)
    EditFile: TEdit;
    Label1: TLabel;
    ButtonChooseFile: TButton;
    OpenTextFileDialog1: TOpenTextFileDialog;
    Label2: TLabel;
    EditLong: TEdit;
    Label3: TLabel;
    EditLat: TEdit;
    ButtonOK: TButton;
    Label4: TLabel;
    EditWind: TEdit;
    Bevel1: TBevel;
    Label5: TLabel;
    EditAPI: TEdit;

    EditWeatherFilename: TEdit;
    OpenTextFileDialog2: TOpenTextFileDialog;
    BitBtn1: TBitBtn;
    CheckBoxWD: TCheckBox;
    Label6: TLabel;
    EditSecondsUpdate: TEdit;
    procedure ButtonChooseFileClick(Sender: TObject);
    procedure ButtonOKClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure BitBtn1Click(Sender: TObject);

  private
    { Private declarations }
  public
    { Public declarations }
    { var
      Windspeed,
      Longitude,
      Latitude, }
    RFilename: String;
    WFileName: String;
  end;

var
  SetupForm: TSetupForm;

implementation

uses Main;
{$R *.dfm}

procedure TSetupForm.BitBtn1Click(Sender: TObject);
begin
  if OpenTextFileDialog2.Execute = True then
  begin
    WFileName := OpenTextFileDialog2.FileName
  end;
  EditWeatherFilename.Text := WFileName
end;

procedure TSetupForm.ButtonChooseFileClick(Sender: TObject);
begin
  if OpenTextFileDialog1.Execute = True then
  begin
    RFilename := OpenTextFileDialog1.FileName
  end;
  EditFile.Text := RFilename
end;

procedure TSetupForm.ButtonOKClick(Sender: TObject);
begin
  MainForm.Longitude := EditLong.Text;
  MainForm.Latitude := EditLat.Text;
  MainForm.MaxWindSpeed := EditWind.Text;
  MainForm.RoofFileName := EditFile.Text;
  MainForm.WeatherFilename := EditWeatherFilename.Text;
  MainForm.SaveWeather := CheckBoxWD.Checked;
  MainForm.UpdateSeconds := StrToInt(EditSecondsUpdate.Text);
  MainForm.WriteSettings;
  // Lägg ev. till test av validitet.
  // Komma ersätts av punkt t.ex
  Close
end;

procedure TSetupForm.FormActivate(Sender: TObject);
begin
  EditLong.Text := MainForm.Longitude;
  EditLat.Text := MainForm.Latitude;
  EditWind.Text := MainForm.MaxWindSpeed;
  EditFile.Text := MainForm.RoofFileName;
  EditSecondsUpdate.Text := IntToStr(MainForm.UpdateSeconds);
  EditWeatherFilename.Text := MainForm.WeatherFilename;
  EditAPI.Text := MainForm.API_Key;
  CheckBoxWD.Checked := MainForm.SaveWeather;
end;

end.
