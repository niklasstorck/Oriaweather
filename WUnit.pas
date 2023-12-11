unit WUnit;

interface

uses
  System.Generics.Collections,
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, System.Net.HttpClientComponent, System.Net.URLClient,
  System.Net.HttpClient, Vcl.StdCtrls, System.JSON;

type
  TWeather = class
    City,
    clouds,
    windspeed,
    rain,
    winddirection: String;
    Temperature,
    Longitude,
    Latitude: Double;

    procedure GetWeather;
  private
    { Private declarations }
  public
    { Public declarations }
  end;





implementation



procedure TWeather.GetWeather;
var
  HttpClient: TNetHTTPClient;
  URL: string;
  Response: IHTTPResponse;
  JSONValue: TJSONValue;
  MainObject, WeatherObject: TJSONObject;
  // City, Country,
  Description,
  Temperature: string;
begin
  HttpClient := TNetHTTPClient.Create(nil);
  try
    URL := 'https://api.openweathermap.org/data/2.5/weather?q=' + City + '&units=metric&APPID=YOUR_API_KEY_HERE';
    Response := HttpClient.Get(URL);
    if Response.StatusCode = 200 then
    begin
      JSONValue := TJSONObject.ParseJSONValue(Response.ContentAsString);
      try
        MainObject := JSONValue.GetValue<TJSONObject>('main');
        WeatherObject := JSONValue.GetValue<TJSONArray>('weather').Items[0] as TJSONObject;

        City := JSONValue.GetValue<string>('name');
        //Country := JSONValue.GetValue<TJSONObject>('sys').GetValue<string>('country');
        Description := WeatherObject.GetValue<string>('description');
        Temperature := FormatFloat('0.#', MainObject.GetValue<Double>('temp')) + ' °C';

        //lblCity.Caption := 'City: ' + City;
        //lblCountry.Caption := 'Country: ' + Country;
        //lblDesc.Caption := 'Description: ' + Description;
        //lblTemp.Caption := 'Temperature: ' + Temperature;
      finally
        JSONValue.Free;
      end;
    end
    else
      ShowMessage('Error: ' + Response.StatusCode.ToString + ' ' + Response.StatusText);
  finally
    HttpClient.Free;
  end;
end;

end.

