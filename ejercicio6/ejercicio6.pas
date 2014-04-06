
uses arch, persona;

procedure CargarPersona(var A:apersonas);
var
	nombre, apellido: String[20];
	dni, fechanacimiento: Longword;
	P: tpersona;
	exito:boolean;
begin
	writeln('Escriba su nombre: ');
	read(nombre);
	writeln('Escriba su apellido: ');
	read(apellido);
	writeln('Escriba su dni: ');
	read(dni);
	writeln('Escriba su fecha de nacimiento: ');
	read(fechanacimiento);
	writeln;
	Crear(nombre, apellido, dni, fechanacimiento, P);
	Insertar(A,P,exito);
	if (exito) then	writeln('La persona se ha argregado exitosamente. ')
	else	writeln('En el archivo ya existía un registro con el mismo DNI.');
end;
procedure CargarPersonas(var A:apersonas);
var
	opcion:string[5];
begin
	writeln('Si desea cargar una nueva persona escriba la "u" y si desea terminar el archivo escriba "d".');
	read(opcion);
	while (opcion[0]<>'d') do
	begin
		while ((opcion[0]<>'u') or (opcion[0]<>'d')) do
			read(opcion);
		if (opcion[0] ='u') then	CargarPersona(A);
	end;
end;

var
	Archivo:apersonas;
    exp:Text;
begin
	CrearArchivo(Archivo, 'registros'); //proceso del UNIT
	CargarPersonas(Archivo); //proceso del programa
	Exportar(Archivo, exp, 'exportado.txt')//implementar las demás funciones
end.
