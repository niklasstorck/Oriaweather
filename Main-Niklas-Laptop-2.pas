unit Main;

interface

uses
  System.Generics.Collections, Setup, inifiles, system.StrUtils,  system.UITypes,
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, System.Net.HttpClientComponent, System.Net.URLClient,
  System.Net.HttpClient, Vcl.StdCtrls, System.JSON, Vcl.ExtCtrls, Vcl.Menus;

type
  TMainForm = class(TForm)

    Memo1: TMemo;
    Timer1: TTimer;
    PopupMenu1: TPopupMenu;
    Instllningar1: TMenuItem;

    procedure GetWeather(La, Lo : String);

    procedure FormCreate(Sender: TObject);
    procedure UpdateWeather(Lat,Long : String);
    procedure Timer1Timer(Sender: TObject);
    procedure SettingsClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormShow(Sender: TObject);

  private
    { Private declarations }

    //Roofstatus: Boolean;
    FileReadErrors: Integer;
    LatestWUpdate,
    LatestUpdate: TDateTime;

    function IsFileInUse(FileName: TFileName): Boolean;
    procedure WriteSettings;
    procedure ReadSettings;
    procedure WriteBoltwoodFile;
    procedure SaveWeatherData;
    procedure WriteLogFile(S: String);
    function Roofopen(FN: String):boolean;

  public
    { Public declarations }
    API_Key,
    City,
    country,
    clouds,
    windspeed,
    rain,
    winddirection,
    windgust,
    Humidity,
    Temperature,
    Roofstatus : String;
    SaveWeather: Boolean;
    OK : Boolean;
    RoofFileName,
    WeatherFilename,
    Longitude,
    Latitude,
    MaxWindSpeed: String;

  end;



var
  MainForm: TMainForm;

implementation

{$R *.dfm}

function TMainForm.IsFileInUse(FileName: TFileName): Boolean;
var
  HFileRes: HFILE;
begin
  Result := False;
  if not FileExists(FileName) then Exit;
  HFileRes := CreateFile(PChar(FileName),
                         GENERIC_READ or GENERIC_WRITE,
                         0,
                         nil,
                         OPEN_EXISTING,
                         FILE_ATTRIBUTE_NORMAL,
                         0);
  Result := (HFileRes = INVALID_HANDLE_VALUE);
  if not Result then
    CloseHandle(HFileRes);
end;

(*
  Get weather data from openweather
*)
procedure TMainForm.GetWeather(La, Lo: String);
var
  HttpClient: TNetHTTPClient;
  URL: string;
  Response: IHTTPResponse;
  JSONValue: TJSONValue;
  WindObject, MainObject, WeatherObject: TJSONObject;
  FS: TFormatsettings;

  // City, Country,
begin
  FS := TFormatsettings.Create('en-US');
  HttpClient := TNetHTTPClient.Create(nil);
  try

    URL := 'http://api.openweathermap.org/data/2.5/weather?lat=' + La + '&lon='
      + Lo + '&units=metric&APPID=' + API_Key;
    Response := HttpClient.Get(URL);

    if Response.StatusCode = 200 then
    begin
      JSONValue := TJSONObject.ParseJSONValue(Response.ContentAsString);
      try
        MainObject := JSONValue.GetValue<TJSONObject>('main');
        WeatherObject := JSONValue.GetValue<TJSONArray>('weather')
          .Items[0] as TJSONObject;
        WindObject := JSONValue.GetValue<TJSONObject>('wind');
        City := JSONValue.GetValue<string>('name');
        country := JSONValue.GetValue<TJSONObject>('sys').GetValue<string>('country');
        clouds := WeatherObject.GetValue<string>('description');
        Temperature := FormatFloat('0.#', MainObject.GetValue<Double>('temp'), FS);
        windspeed := FormatFloat('0.#', WindObject.GetValue<Double>('speed'), FS);
        winddirection := FormatFloat('0.#', WindObject.GetValue<Double>('deg'), FS);
        windgust := FormatFloat('0.#', WindObject.GetValue<Double>('gust'), FS);
        Humidity := FormatFloat('0.#', MainObject.GetValue<Double>('humidity'), FS);
      finally
        JSONValue.Free;
      end;
    end
    else
      WriteLogFile('Error (openweather.com): ' + Response.StatusCode.ToString + ' ' +
        Response.StatusText);

  finally
    HttpClient.Free;
    SaveWeatherData;
  end;
  LatestUpdate := Now;
end;


procedure TMainForm.WriteBoltwoodFile;
var S, Stmp: String;
    F: Textfile;
    FormatS : TFormatsettings;
    T : Tdatetime;
    i :Integer;
begin
  FormatS := TFormatsettings.Create('sw-SE');
  // Write a Boltwood compatible weather data file
  S := DateTimeToStr(Now,FormatS);
  // C = Celsius K = knop -30 is skytemperature.
  S := S + ' C K 30.0 ';
  S := S + Temperature;
  // Sensortemperature I dont have -> set to 20
  S := S + ' 20.0 ';
  // 30 = relative humidity. We can add later
  S := S + windspeed + ' 30 ';
  // Dew Point  Dew Heater Percentage Rain Flag Wet Flag
  S := S + ' 56.1   000 0 0 ';
  // Time since last write Måste formateras
  //S := S + FloatToStr((Now - MainForm.LatestUpdate)*86400) +' ';
  S := S + '00020 ';
  // Days since last write
  T := Now - LatestUpdate;
  STmp := FloatToStr(T);
  S := S + STmp;
  S := S + ' 1 1 1 1 ';

  if Roofstatus = ' öppet' then
     STmp := '0 '
  else STmp := '1 ';
  S := S + STmp;

  if OK then
     STmp := '0'
  else STmp := '1';
  S := S + Stmp;

  // Kontrollera att filen inte är låst och skriv bara om den inte är låst
  // Test fem ggr.
  i := 0;
  while (i < 5) and IsFileInUse('weatherfile.txt') do
  begin
    Inc(i);
    Sleep(500);
  end;

  if i < 5  then
    begin
    AssignFile(F,'weatherfile.txt');
    Rewrite(F);
    Write(F,S);
    CloseFile(F);
    LatestUpdate := Now
    end
  else
    begin
    Memo1.Lines.Clear;
    Memo1.Color := RGB(200,200,50);
    Memo1.Lines.Add('Problem att skriva till weatherfile.');
    Memo1.Lines.Add('Filen är låst av en annan application!')
    end;

end;

procedure TMainForm.WriteLogFile(S: String);
const LogFile = 'openweather.log';
var F: Textfile;
    FS : TFormatsettings;
    T: String;
begin
   FS := TFormatsettings.Create('sw-SE');
   FS.LongDateFormat:='YYYY-MM-DD';
   FS.ShortDateFormat:='YYYY-MM-DD';
   T:= DateTimeToStr(now,FS);
   AssignFile(F,LogFile);
   if FileExists(LogFile) then begin
     Append(F);
     WriteLn(F,T + ' '+ S);
     CloseFile(F)
     end
   else begin
     Rewrite(F);
     WriteLn(F,T + ' '+ S);
     CloseFile(F);
   end;
end;

procedure TMainForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  WriteSettings;
  //if MessageDlg('Om du stänger av programet slutar väderinformationen till ACP.',mtConfirmation, [mbOK], 0) = mrOK then
  //  Close
end;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  LatestUpdate := Now - 0.000694;  // Ca 58 sekunder
  LatestWUpdate := Now - 0.00257;  // Ca fem minuter
  Memo1.Lines.Clear;
  ReadSettings;
  FileReadErrors := 0;
end;


procedure TMainForm.FormShow(Sender: TObject);
begin
  Memo1.lines.Add('Väntar på Openweather.com');
  Show;
  UpdateWeather(Latitude,Longitude)
end;

procedure TMainForm.ReadSettings;
var Inifile: TInifile;
begin
  // Read settings from inifile
  IniFile   := TIniFile.Create(ChangeFileExt(Application.ExeName, '.ini'));
  RoofFileName  := IniFile.ReadString('Settings','RoofFile','');
  WeatherFileName := IniFile.ReadString('Settings','WeatherFName','SavedWeather.csv');
  Longitude     := IniFile.ReadString('Settings','Longitude','');
  Latitude      := IniFile.ReadString('Settings','Latitude','');
  MaxWindSpeed  := IniFile.ReadString('Settings','MaxWindSpeed','');
  API_Key       := IniFile.ReadString('Settings','API_Key','8058d6b899f910dd98691072cb8fe034');
  Top           := IniFile.ReadInteger('Place','Top', 20);
  Left          := IniFile.ReadInteger('Place','Left', 20);
  SaveWeather   := Inifile.ReadBool('Settings','SaveWeather',true);
  IniFile.Destroy
end;

procedure TMainForm.WriteSettings;
var IniFile: TInifile;
begin
  // Write settings from inifile
  IniFile   := TIniFile.Create(ChangeFileExt(Application.ExeName, '.ini'));
  IniFile.WriteString('Settings','RoofFile',RoofFileName);
  IniFile.WriteString('Settings','WeatherFName',WeatherFileName);
  IniFile.WriteString('Settings','Longitude',Longitude);
  IniFile.WriteString('Settings','Latitude',Latitude);
  IniFile.WriteString('Settings','MaxWindSpeed',MaxWindSpeed);
  IniFile.WriteString('Settings','API_Key',API_Key);
  IniFile.WriteInteger('Place','Top',Top);
  IniFile.WriteInteger('Place','Left',Left);
  Inifile.WriteBool('Settings','SaveWeather', SaveWeather);
  Inifile.Destroy;
end;


function TMainForm.Roofopen(FN: String): boolean;
var F: Textfile;
    S, R: String;
    p, filehandle : Integer;
begin
  // Kontrollera om taket är öppet. True if open
  FileReadErrors:= 0;

  try
   if not FileExists(FN) then
      WriteLogFile('File: ' + FN + ' not found');

   filehandle:=  FileOpen(FN, fmOpenRead);
   if (filehandle = -1) then
      Inc(FileReadErrors);

   if FileReadErrors > 3 then begin
      WriteLogFile('Filen: ' + FN + ' kan inte öppnas efter tre försök.');
      Roofopen := False
   end

   else begin   // Check if roof is open
     FileClose(filehandle);
     FileReadErrors := 0;
     AssignFile(F,FN);
     Reset(F);
     ReadLn(F,S);
     p := Pos(': ',S)+2;
     R := Copy(S,p,4);
     if R = 'OPEN' then
        Roofopen := true
     else Roofopen := false;
     CloseFile(F);
     Sleep(500)
   end;


  Except
    RoofOpen:= false;   // False om inte roofstatusfilen kan hittas, eller är låst.
    //WriteLogFile('Kan inte  hitta roof-filen: ')
  end;
end;

procedure TMainForm.SaveWeatherData;
  // Spara väderdata till fil
  Const Separator = ','; // #9 is ascii for tab
  var
    F: Textfile;
    FS : TFormatsettings;
    S: String;
begin
  FS := TFormatsettings.Create('sw-SE');
  FS.LongDateFormat:='YYYY-MM-DD';
  FS.ShortDateFormat:='YYYY-MM-DD';
  S := DateTimeToStr(Now,FS);
  S := S + Separator;
  S := S + windspeed + Separator + windgust + Separator  + winddirection + Separator + BooltoStr(OK,True);

  if FileExists(WeatherFilename) then
  begin
    // Adds a line to the file
    AssignFile(F,WeatherFilename);
    Append(F);
    WriteLn(F,S);
    CloseFile(F)
  end
  else
  begin
    // If file is nonexistent -> create it
    AssignFile(F,WeatherFilename);
    Rewrite(F);
    S := ' Vinddata Oria.';
    WriteLn(F,S);
    S := ' Longitude: ' + Longitude + ' Latitude: ' + Latitude;
    WriteLn(F,S);
    S := '*******************************************************************';
    WriteLn(F,S);
    S := 'Datum:tid'+Separator+'Hastighet (m/S)'+Separator+'Byar (m/s)'+Separator+'Vindriktning (grader)'+Separator+'OK?';
    WriteLn(F,S);
    CloseFile(F);

    // Recursiv call of this function the first time it
    // creates the file. Now it exists.
    SaveWeatherdata;
  end;
end;

procedure TMainForm.SettingsClick(Sender: TObject);
begin
  SetupForm.Show;
end;

procedure TMainForm.Timer1Timer(Sender: TObject);
begin
  UpdateWeather(Latitude, Longitude);
  //SaveWeatherdata;
end;

procedure TMainForm.UpdateWeather(Lat,Long : String);
var FSe, FSs : TFormatsettings;
    T: Real;
begin
  try
    // Vädret uppdateras var femte minut men Boltwoodfilen
    // måste uppdateras oftare än var 60e sekund.

    // US format för beräkningar, Svensk för presentation.
    FSe := TFormatsettings.Create('en-US');
    FSs := TFormatsettings.Create('se-SE');
    // Uppdatera vädret var femte minut
    T := Now - LatestWUpdate;
    if T > (0.00255) then // Borde ha gått fem minuter
    begin
      GetWeather(Lat,Long);
      LatestWUpdate := Now;
    end;

    Memo1.Lines.Clear;

    Memo1.lines.Add('Plats (enligt Openweather) : ' + City + ', '+ country);
    Memo1.Lines.Add('Latitude  : '+Lat);
    Memo1.Lines.Add('Longitude : '+Long);
    Memo1.Lines.Add('***********************************');
    Memo1.Lines.Add('Takstatus uppdaterat : ' + TimetoStr(Now,FSs));
    Memo1.Lines.Add('Vädret uppdaterat    : ' + TimeToStr(LatestWUpdate, FSs));
    Memo1.Lines.Add('Temperatur           : ' + Temperature + ' °C');
    Memo1.Lines.Add('Luftfuktighet        : ' + Humidity + ' %');
    Memo1.Lines.Add('Molninghet           : ' + clouds);
    Memo1.Lines.Add('Vind (medel)         : ' + windspeed + ' m/s');
    Memo1.Lines.Add('Vind (max)           : ' + windgust + ' m/s');
    Memo1.Lines.Add('Vindriktning         : ' + winddirection + '°');

    if RoofOpen(MainForm.RoofFileName) then
       Roofstatus := ' öppet'
    else Roofstatus := ' stängt';
    Memo1.Lines.Add('Taket är             :' + Roofstatus);

    if FileReadErrors > 0 then
       WriteLogFile('Antal läsfel på roofstatusfilen :' + IntToStr(FileReadErrors));


    if (Roofstatus = ' öppet')  and (StrToFloat(windspeed,FSe) < StrToFloat(MaxWindSpeed, FSe)) then
      OK := true
    else OK:=false;

    if OK then
      Memo1.Brush.Color:=RGB(128,230,128)
    else Memo1.Brush.Color:=RGB(230,128,128);

    WriteBoltwoodFile;
    LatestUpdate := Now;
  finally
  end;

end;


end.
