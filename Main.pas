unit Main;

interface

uses
        System.Generics.Collections, Setup, inifiles, System.StrUtils,
        System.UITypes,   InformationScreen,
        Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
        System.Classes, Vcl.Graphics,
        Vcl.Controls, Vcl.Forms, Vcl.Dialogs, System.Net.HttpClientComponent,
        System.Net.URLClient,
        System.Net.HttpClient, Vcl.StdCtrls, System.JSON, Vcl.ExtCtrls,
        Vcl.Menus;

type
        TMainForm = class(TForm)

                Memo1: TMemo;
                Timer1: TTimer;
                PopupMenu1: TPopupMenu;
                Instllningar1: TMenuItem;
    Readme1: TMenuItem;

                procedure GetWeather(La, Lo: String);

                procedure FormCreate(Sender: TObject);
                procedure UpdateWeather(Lat, Long: String);
                procedure Timer1Timer(Sender: TObject);
                procedure SettingsClick(Sender: TObject);
                procedure FormClose(Sender: TObject; var Action: TCloseAction);
                procedure FormShow(Sender: TObject);
                procedure WriteSettings;
    procedure Readme1Click(Sender: TObject);
        private
                { Private declarations }

                // Roofstatus: Boolean;
                LogLevel, RoofFileReadErrors: Integer;
                LatestWUpdate, LatestUpdate: TDateTime;

                function IsFileInUse(FileName: TFileName): Boolean;

                procedure ReadSettings;
                procedure WriteBoltwoodFile;
                procedure SaveWeatherData;
                procedure WriteLogFile(S: String; L: Integer);
                function Roofopen(FN: String): Boolean;

        public
                { Public declarations }
                API_Key, City, country, clouds, windspeed, rain, winddirection,
                  windgust, Humidity, Temperature, Roofstatus: String;
                UpdateSeconds: Integer; // Tid mellan uppdatering av väderfil
                SaveWeather: Boolean;
                OK: Boolean;
                RoofFileName, WeatherFilename, Longitude, Latitude,
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
        if not FileExists(FileName) then
                Exit;
        HFileRes := CreateFile(PChar(FileName), GENERIC_READ or GENERIC_WRITE,
          0, nil, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0);
        Result := (HFileRes = INVALID_HANDLE_VALUE);
        if not Result then
                CloseHandle(HFileRes);
end;

// Get weather data from openweather
procedure TMainForm.GetWeather(La, Lo: String);

var
        HttpClient: TNetHTTPClient;
        URL: string;
        Response: IHTTPResponse;
        JSONValue: TJSONValue;
        WindObject, MainObject, WeatherObject: TJSONObject;
        FS: TFormatsettings;

begin
        FS := TFormatsettings.Create('en-US');
        HttpClient := TNetHTTPClient.Create(nil);
        try

                URL := 'http://api.openweathermap.org/data/2.5/weather?lat=' +
                  La + '&lon=' + Lo + '&units=metric&APPID=' + API_Key;
                Response := HttpClient.Get(URL);

                if Response.StatusCode = 200 then
                begin
                        JSONValue := TJSONObject.ParseJSONValue
                          (Response.ContentAsString);
                        try
                                MainObject :=
                                  JSONValue.GetValue<TJSONObject>('main');
                                WeatherObject := JSONValue.GetValue<TJSONArray>
                                  ('weather').Items[0] as TJSONObject;
                                WindObject :=
                                  JSONValue.GetValue<TJSONObject>('wind');
                                City := JSONValue.GetValue<string>('name');
                                country := JSONValue.GetValue<TJSONObject>
                                  ('sys').GetValue<string>('country');
                                clouds := WeatherObject.GetValue<string>
                                  ('description');
                                Temperature :=
                                  FormatFloat('0.#',
                                  MainObject.GetValue<Double>('temp'), FS);
                                windspeed :=
                                  FormatFloat('0.#',
                                  WindObject.GetValue<Double>('speed'), FS);
                                winddirection :=
                                  FormatFloat('0.#',
                                  WindObject.GetValue<Double>('deg'), FS);
                                windgust :=
                                  FormatFloat('0.#',
                                  WindObject.GetValue<Double>('gust'), FS);
                                Humidity :=
                                  FormatFloat('0.#',
                                  MainObject.GetValue<Double>('humidity'), FS);
                        finally
                                JSONValue.Free;
                        end;
                end
                else
                        WriteLogFile('Error från Openweather API: ' +
                          Response.StatusCode.ToString + ' ' +
                          Response.StatusText, 1);

        finally
                HttpClient.Free;
                SaveWeatherData;
        end;
        LatestUpdate := Now;
end;

procedure TMainForm.WriteBoltwoodFile;
var
        S, Stmp: String;
        F: Textfile;
        FormatS, FormatE: TFormatsettings;
        T: TDateTime;
        i: Integer;
begin
        FormatS := TFormatsettings.Create('sw-SE');
        FormatS.LongDateFormat := 'YYYY-MM-DD';
        FormatS.ShortDateFormat := 'YYYY-MM-DD';
        FormatE := TFormatsettings.Create('en-US');
        // Write a Boltwood compatible weather data file
        S := DateTimeToStr(Now, FormatS);
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
        S := S + '00020 ';
        // Days since last write
        // Changed to time of last write  230725 /NS
        T := Now;
        Stmp := FloatToStr(T, FormatS);
        S := S + Stmp;
        S := S + ' 1 1 1 1 ';

        if Roofstatus = ' öppet' then
                Stmp := '0 '
        else
                Stmp := '1 ';

        S := S + Stmp;

        if OK then
                Stmp := '0'
        else
                Stmp := '1';
        S := S + Stmp;

        // Kontrollera att filen inte är låst och skriv bara om den inte är låst
        // Test fem ggr.
        i := 0;
        while (i < 5) and IsFileInUse('weatherfile.txt') do
        begin
                Inc(i);
                Sleep(500);
        end;

        if i < 5 then
        begin
                AssignFile(F, 'weatherfile.txt');
                Rewrite(F);
                Write(F, S);
                CloseFile(F);
                LatestUpdate := Now;
                WriteLogFile(FloatToStr(Now, FormatE) + ' weatherfile.txt', 2);
        end
        else
        begin
                Memo1.Lines.Clear;
                Memo1.Color := RGB(200, 200, 50);
                WriteLogFile('Problem att skriva till weatherfile.txt', 1);
                WriteLogFile('Filen är låst av en annan application!', 1);
        end;

end;

procedure TMainForm.WriteLogFile(S: String; L: Integer);
const
        LogFile = 'openweather.log';
var
        F: Textfile;
        FS: TFormatsettings;
        T: String;
begin
        FS := TFormatsettings.Create('sw-SE');
        FS.LongDateFormat := 'YYYY-MM-DD';
        FS.ShortDateFormat := 'YYYY-MM-DD';
        T := DateTimeToStr(Now, FS);
        if L <= LogLevel then
        begin
                AssignFile(F, LogFile);
                if FileExists(LogFile) then // Lägg till i befintlig fil
                begin
                        Append(F);
                        WriteLn(F, T + ' ' + S)
                end
                else // Gör en ny fil och skriv till den
                begin
                        Rewrite(F);
                        WriteLn(F, T + ' ' + S)
                end;
                CloseFile(F)
        end;
end;

procedure TMainForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
        WriteSettings;
        WriteLogFile('Oriaweather avslutas.', 1)
end;

procedure TMainForm.FormCreate(Sender: TObject);
begin
        ReadSettings;
        Timer1.Interval := UpdateSeconds * 1000;
        LatestUpdate := Now - (UpdateSeconds / (3600 * 24)); // Ca  sekunder
        LatestWUpdate := Now - (5 / (60 * 24)); // Ca fem minuter
        RoofFileReadErrors := 0;
        Memo1.Lines.Clear;
        Caption := 'Oriaweather V. 1.3';
        WriteLogFile('Oriaweather startar.', 1);
        WriteLogFile('LogLevel : ' + IntToStr(LogLevel), 0)
end;

procedure TMainForm.FormShow(Sender: TObject);
begin
        Show;
        WriteLogFile('Väntar på Openweather.com', 1);
        UpdateWeather(Latitude, Longitude)
end;

procedure TMainForm.Readme1Click(Sender: TObject);
begin
  Info.ShowModal
end;

procedure TMainForm.ReadSettings;
var
        Inifile: TInifile;
begin
        // Read settings from inifile
        Inifile := TInifile.Create(ChangeFileExt(Application.ExeName, '.ini'));
        RoofFileName := Inifile.ReadString('Settings', 'RoofFile', '');
        WeatherFilename := Inifile.ReadString('Settings', 'WeatherFName',
          'SavedWeather.csv');
        Longitude := Inifile.ReadString('Settings', 'Longitude', '');
        Latitude := Inifile.ReadString('Settings', 'Latitude', '');
        MaxWindSpeed := Inifile.ReadString('Settings', 'MaxWindSpeed', '');
        API_Key := Inifile.ReadString('Settings', 'API_Key',
          '8058d6b899f910dd98691072cb8fe034');
        Top := Inifile.ReadInteger('Place', 'Top', 20);
        Left := Inifile.ReadInteger('Place', 'Left', 20);
        SaveWeather := Inifile.ReadBool('Settings', 'SaveWeather', true);
        LogLevel := Inifile.ReadInteger('Logging', 'LogLevel', 1);
        UpdateSeconds := Inifile.ReadInteger('Settings', 'UppdateSec', 15);
        Inifile.Destroy
end;

procedure TMainForm.WriteSettings;
var
        Inifile: TInifile;
begin
        // Write settings from inifile
        Inifile := TInifile.Create(ChangeFileExt(Application.ExeName, '.ini'));
        Inifile.WriteString('Settings', 'RoofFile', RoofFileName);
        Inifile.WriteString('Settings', 'WeatherFName', WeatherFilename);
        Inifile.WriteString('Settings', 'Longitude', Longitude);
        Inifile.WriteString('Settings', 'Latitude', Latitude);
        Inifile.WriteString('Settings', 'MaxWindSpeed', MaxWindSpeed);
        Inifile.WriteString('Settings', 'API_Key', API_Key);
        Inifile.WriteInteger('Settings', 'UppdateSec', UpdateSeconds);
        Inifile.WriteInteger('Place', 'Top', Top);
        Inifile.WriteInteger('Place', 'Left', Left);
        Inifile.WriteBool('Settings', 'SaveWeather', SaveWeather);
        // Logging ändras direkt i inifilen och behöver inte sparas
        // från programet. NI 2023-07-27
        Inifile.WriteInteger('Logging', 'LogLevel', LogLevel);
        Inifile.Destroy;
end;

function TMainForm.Roofopen(FN: String): Boolean;
var
        F: Textfile;
        S, R: String;
        p, filehandle: Integer;
begin
        // Kontrollera om taket är öppet. True if open
        // RoofFileReadErrors:= 0;

        try
                if not FileExists(FN) then
                        WriteLogFile('File: ' + FN + ' not found', 1);

                filehandle := FileOpen(FN, fmOpenRead);
                if (filehandle = -1) then
                        Inc(RoofFileReadErrors);

                if RoofFileReadErrors > 3 then
                begin
                        WriteLogFile('Filen: ' + FN +
                          ' kan inte öppnas efter tre försök.', 1);
                        Roofopen := False
                end

                else
                begin // Check if roof is open
                        FileClose(filehandle);
                        RoofFileReadErrors := 0;
                        AssignFile(F, FN);
                        Reset(F);
                        ReadLn(F, S);
                        p := Pos(': ', S) + 2;
                        R := Copy(S, p, 4);
                        if R = 'OPEN' then
                                Roofopen := true
                        else
                                Roofopen := False;
                        CloseFile(F);
                        WriteLogFile('Filen: ' + FN + ' öppnad ua.', 2);
                        Sleep(500)
                end;

        Except
                Roofopen := False;
                // False om inte roofstatusfilen kan hittas, eller är låst.
                WriteLogFile('Filen: ' + FN + ' kan inte öppnas.', 1);
                // WriteLogFile('Kan inte  hitta roof-filen: ')
        end;
end;

procedure TMainForm.SaveWeatherData;
// Spara väderdata till fil en rad var femte minut
Const
        Separator = ','; // #9 is ascii for tab
var
        F: Textfile;
        FS: TFormatsettings;
        S: String;
begin
        FS := TFormatsettings.Create('sw-SE');
        FS.LongDateFormat := 'YYYY-MM-DD';
        FS.ShortDateFormat := 'YYYY-MM-DD';
        S := DateTimeToStr(Now, FS);
        S := S + Separator;
        S := S + windspeed + Separator + windgust + Separator + winddirection +
          Separator + BooltoStr(OK, true);

        if FileExists(WeatherFilename) then
        begin
                // Adds a line to the file
                AssignFile(F, WeatherFilename);
                Append(F);
                WriteLn(F, S);
                CloseFile(F)
        end
        else
        begin
                // If file is nonexistent -> create it
                AssignFile(F, WeatherFilename);
                Rewrite(F);
                S := ' Vinddata Oria.';
                WriteLn(F, S);
                S := ' Longitude: ' + Longitude + ' Latitude: ' + Latitude;
                WriteLn(F, S);
                S := '*******************************************************************';
                WriteLn(F, S);
                S := 'Datum:tid' + Separator + 'Hastighet (m/S)' + Separator +
                  'Byar (m/s)' + Separator + 'Vindriktning (grader)' +
                  Separator + 'OK?';
                WriteLn(F, S);
                CloseFile(F);

                // Recursiv call of this function the first time it
                // creates the file. Now it exists.
                SaveWeatherData;
        end;
end;

procedure TMainForm.SettingsClick(Sender: TObject);
begin
        SetupForm.Show;
end;

procedure TMainForm.Timer1Timer(Sender: TObject);
begin
        UpdateWeather(Latitude, Longitude);
end;

procedure TMainForm.UpdateWeather(Lat, Long: String);
var
        FSe, FSs: TFormatsettings;
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
                // Om det har gått fem minuter
                // Uppdatera från Openweather.com
                if T > (0.00255) then
                begin
                        GetWeather(Lat, Long);
                        LatestWUpdate := Now;
                end;

                // Uppdatera displayen
                // och skriv till boltwoodfilen
                // oavsett om Vädret är uppdaterat, eller ej.
                Memo1.Lines.Clear;

                Memo1.Lines.Add('Plats (enligt Openweather) : ' + City + ', '
                  + country);
                Memo1.Lines.Add('Latitude  : ' + Lat);
                Memo1.Lines.Add('Longitude : ' + Long);
                Memo1.Lines.Add('***********************************');
                Memo1.Lines.Add('Takstatus uppdaterat : ' +
                  TimetoStr(Now, FSs));
                Memo1.Lines.Add('Vädret uppdaterat    : ' +
                  TimetoStr(LatestWUpdate, FSs));
                Memo1.Lines.Add('Temperatur           : ' + Temperature
                  + ' °C');
                Memo1.Lines.Add('Luftfuktighet        : ' + Humidity + ' %');
                Memo1.Lines.Add('Molninghet           : ' + clouds);
                Memo1.Lines.Add('Vind (medel)         : ' + windspeed + ' m/s');
                Memo1.Lines.Add('Vind (max)           : ' + windgust + ' m/s');
                Memo1.Lines.Add('Vindriktning         : ' +
                  winddirection + '°');

                if Roofopen(MainForm.RoofFileName) then
                        Roofstatus := ' öppet'
                else
                        Roofstatus := ' stängt';

                Memo1.Lines.Add('Taket är             :' + Roofstatus);

                if (Roofstatus = ' öppet') and
                  (StrToFloat(windspeed, FSe) < StrToFloat(MaxWindSpeed, FSe))
                then
                        OK := true
                else
                        OK := False;

                if OK then
                        Memo1.Brush.Color := RGB(128, 230, 128)
                else
                        Memo1.Brush.Color := RGB(230, 128, 128);
                WriteLogFile('Booltwodfil är uppdaterat', 2);
                WriteBoltwoodFile;
                LatestUpdate := Now;
        finally
        end;

end;

end.
