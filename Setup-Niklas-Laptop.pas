unit Setup;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtDlgs, Vcl.StdCtrls;

type
  TSetupForm = class(TForm)
    Edit1: TEdit;
    Label1: TLabel;
    Button1: TButton;
    OpenTextFileDialog1: TOpenTextFileDialog;
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  SetupForm: TSetupForm;

implementation

{$R *.dfm}

procedure TSetupForm.Button1Click(Sender: TObject);
begin
  while OpenTextfileDialog1.Execute do
    Edit1.Text := OpenTextfileDialog1.FileName

end;

end.
