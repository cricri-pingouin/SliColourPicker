program colpick;

uses
  Forms,
  Unit1 in 'Unit1.pas' {Form1};

{$R *.res}
{$SetPEFlags 1}

begin
  Application.Initialize;
  Application.Title := 'Colour Picker';
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
