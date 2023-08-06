unit Main;

interface

uses
  System.Generics.Collections, Setup,
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, System.Net.HttpClientComponent, System.Net.URLClient,
  System.Net.HttpClient, Vcl.StdCtrls, System.JSON, Vcl.ExtCtrls, Vcl.Menus;

type
  TForm1 = class(TForm)
    Memo1: TMemo;
    Timer1: TTimer;
    PopupMenu1: TPopupMenu;
    Instllningar1: TMenuItem;

    procedure FormCreate(Sender: TObject);
    procedure UpdateWeather;
    procedure Timer1Timer(Sender: TObject);
    procedure Instllningar1Click(Sender: TObject);
  private
    { Private declarations }

    LatestUpdate: TDateTime;
  public
    { Public declarations }
    Roofstatus: Boolean;
    RoofFile:  Textfile;
  end;

  TWeather = class(TObject)
    Const
      APIKEY = '8058d6b899f910dd98691072cb8fe034';
    procedure GetWeather;
    constructor Create;
  private

  public
    City,
    country,
    clouds,
    windspeed,
    rain,
    winddirection,
    windgust,
    Temperature: String;
    Longitude,
    Latitude: String;

    OK : Boolean;

  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}



constructor TWeather.Create;
begin
   Inherited;
   City := '';
   country := '';
   clouds := '';
   windspeed := '';
   rain := '';
   winddirection := '';
   windgust := '';
   Temperature := '';
   Longitude := '';
   Latitude := '';
   OK := false
end;


procedure TWeather.GetWeather;
var
  HttpClient: TNetHTTPClient;
  URL: string;
  Response: IHTTPResponse;
  JSONValue: TJSONValue;
  WindObject, MainObject, WeatherObject: TJSONObject;
  // City, Country,

begin
  HttpClient := TNetHTTPClient.Create(nil);
  try


    URL := 'http://api.openweathermap.org/data/2.5/weather?lat='+LATITUDE+'&lon='+LONGITUDE+'&units=metric&APPID='+ APIKey;
    Response := HttpClient.Get(URL);
    if Response.StatusCode = 200 then
    begin

      JSONValue := TJSONObject.ParseJSONValue(Response.ContentAsString);
      try
        MainObject      := JSONValue.GetValue<TJSONObject>('main');
        WeatherObject   := JSONValue.GetValue<TJSONArray>('weather').Items[0] as TJSONObject;
        WindObject      := JSONValue.GetValue<TJSONObject>('wind');
        City            := JSONValue.GetValue<string>('name');
        Country         := JSONValue.GetValue<TJSONObject>('sys').GetValue<string>('country');
        clouds          := WeatherObject.GetValue<string>('description');
        Temperature     := FormatFloat('0.#', MainObject.GetValue<Double>('temp')) + ' °C';
        windspeed       := FormatFloat('0.#', WindObject.GetValue<Double>('speed')) + ' m/s';
        winddirection   := FormatFloat('0.#', WindObject.GetValue<Double>('deg')) + '°';
        windgust        := FormatFloat('0.#', WindObject.GetValue<Double>('gust')) + ' m/s';

        if (clouds = 'clear sky') and (WindObject.GetValue<Double>('speed') < 3.0) then
          OK := true
        else OK:=false
      finally
        JSONValue.Free;
        //MainObject.Free;
        //MainObject.Free;
        //WeatherObject.Free
      end;

    end
    else
      ShowMessage('Error: ' + Response.StatusCode.ToString + ' ' + Response.StatusText);
  finally
    HttpClient.Free;
  end;
  Form1.LatestUpdate := Now;
end;


procedure TForm1.FormCreate(Sender: TObject);
begin
  LatestUpdate := Now - 0.000694;
  Memo1.Lines.Clear;
  Memo1.lines.Add('Avvakta uppdatering.');
  RoofFile := SetupForm.Edit1.Text
  // Updateweather
end;

procedure TForm1.Instllningar1Click(Sender: TObject);
begin
  SetupForm.ShowModal
end;

procedure TForm1.Timer1Timer(Sender: TObject);
begin
  UpdateWeather
end;

procedure TForm1.UpdateWeather;
var W: TWeather;
begin
  try
    Memo1.Lines.Clear;
    if (Now - Form1.LatestUpdate) < 0.000693 then
      Memo1.Lines.Add('För tidigt att uppdatera pga begränsning i openweathers API.')
    else
    begin
      W:=Tweather.Create;

      W.Latitude := '37.5';
      W.Longitude := '-2.4';
      W.GetWeather;

      Memo1.Lines.Clear;
      Memo1.lines.Add('Plats       : ' + W.City + ', '+W.country);
      Memo1.Lines.Add('Temperatur  : ' + W.Temperature);
      Memo1.Lines.Add('Molninghet  : ' + W.clouds);
      Memo1.Lines.Add('Vind (medel): ' + W.windspeed);
      Memo1.Lines.Add('Vind (max)  : ' + W.windgust);
      Memo1.Lines.Add('Vindriktning: ' + W.winddirection);
      if W.OK then
        Memo1.Brush.Color:=RGB(128,255,128)
      else Memo1.Brush.Color:=RGB(255,128,128)
    end
  finally
    //W.free
  end;

end;

end.
