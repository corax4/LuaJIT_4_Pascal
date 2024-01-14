unit luajit_sample2_unit;

{$mode objfpc}{$H+}

interface

uses
    Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls, LuaJIT;

type

    TSomeStruct = record
        b: byte;
        i: integer;
        c: pchar;
    end;

    { TForm1 }

    TForm1 = class(TForm)
        btnRun: TButton;
        Memo1: TMemo;
        Memo2: TMemo;
        Panel1: TPanel;
        procedure btnRunClick(Sender: TObject);
    private
        { private declarations }
    public
        { public declarations }
    end;

var
    Form1: TForm1;

function test_fn(a: TSomeStruct): integer;  cdecl;

implementation

function print_func(L: Plua_State): integer; cdecl;
var
    i, c: integer;
begin
    c := lua_gettop(L);
    for i := 1 to c do
        Form1.Memo2.Lines.Add(lua_tostring(L, i));
    Form1.Memo2.SelStart := 0;
    Form1.Memo2.SelLength := 0;
    Result := 0;
end;


function Alloc(ud, ptr: Pointer; osize, nsize: size_t): Pointer; cdecl;
begin
    try
        Result := ptr;
        ReallocMem(Result, nSize);
    except
        Result := nil;
    end;
end;

function test_fn(a: TSomeStruct): integer; cdecl;
begin
    Result := a.i + a.b;
    ShowMessage(a.c);
end;

{$R *.lfm}

{ TForm1 }

procedure TForm1.btnRunClick(Sender: TObject);
var
    L: Plua_State;
    s: string;
    lj_lib_name: string;
begin
    {$IFDEF WINDOWS}
    lj_lib_name := 'lua51.dll';
    {$ELSE}
    lj_lib_name := ExtractFileDir(Application.ExeName) + '/libluajit.so';
    {$ENDIF}

    if LuaLibHandle = 0 then
        if not LuaInit(lj_lib_name) then
        begin
            ShowMessage('Not loaded');
            exit;
        end;

    Memo2.Clear;
    L := lua_newstate(@alloc, nil);
    try
        luaL_openlibs(L);
        lua_register(L, 'print', @print_func);
        try
            s := ' __Addr_test_fn = ' + ({%H-}PtrInt(@test_fn)).ToString;
            if luaL_loadbuffer(L, PChar(s), Length(s), 'preload') <> 0 then
                raise Exception.Create('');
            if lua_pcall(L, 0, 0, 0) <> 0 then
                raise Exception.Create('');

            s := Form1.Memo1.Lines.Text;
            if luaL_loadbuffer(L, PChar(s), Length(s), 'sample2') <> 0 then
                raise Exception.Create('');
            if lua_pcall(L, 0, 0, 0) <> 0 then
                raise Exception.Create('');
        except
            on E: Exception do
            begin
                Form1.Memo2.Lines.Add('Error: ' + E.Message);
                Form1.Memo2.Lines.Add(lua_tostring(L, -1));
                Form1.Memo2.SelStart := 0;
                Form1.Memo2.SelLength := 0;
            end;
        end;
    finally
        lua_close(L);
    end;
end;

end.

