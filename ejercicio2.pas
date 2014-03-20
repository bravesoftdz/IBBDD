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
var
	arch:archivo;
	pri:Text;
	n:int;
Begin
	assign(arch, 'lista.txt');
	assign(pri,'primos.txt')
	n:=0;
	b:=true;
	while(b) do begin
		menu(b);
		case n of
			1: opcion1(arch);
			2: opcion2(arch);
			3: opcion3(arch, pri);
			4: b:=false;
	end;
End.