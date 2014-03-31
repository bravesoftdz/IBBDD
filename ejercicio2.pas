type
	archivo=file of longword;
procedure menu(var op:integer);
begin
	writeln('Elija una opción: ');
	writeln('1 - Crear archivo de números primos');
	writeln('2 - Agregar números primos a un archivo existente');
	writeln('3 - Exportar archivo');
	writeln('4 - Salir');
	readln(op);
end;
procedure calcularPrimos(var ar:archivo, n:integer);
var
	act, num:integer;
	primo:boolean;
begin
	while (not eof(ar)) do
		read(ar, act);
	i:=1;
	while (i<=n) do begin
		seek(ar, 1);
		primo:=true;
		act:=act+1;
		while (not eof(ar) and (primo)) do begin
			read(ar,num);
			if (act mod num = 0) then primo:=false;
			end;
		if (primo) then begin
			i:=i+1;
			seek(ar, filesize(ar));
			write(ar, act);
		end;
end;

{Faltan implementar los procesos opcion1, opcion2 y opcion3}

var
	arch:archivo;
	pri:Text;
	n:int;
Begin
	assign(arch, 'primos');
	assign(pri,'primos.txt')
	n:=0;
	b:=true;
	while(b) do begin
		menu(n);
		case n of
			1: opcion1(arch);
			2: opcion2(arch);
			3: opcion3(arch, pri);
			4: b:=false;
	end;
End.