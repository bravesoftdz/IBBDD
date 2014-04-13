UNIT arch;
interface
	uses sysutils;
	type
        tpersona = Packed Record
				valido:boolean;
                DNI:Longword;
				Apellido:String;
				Nombre:String;
				FechaNac:Longword;
		end;
		archivo = File of tpersona;
		libres = File of integer;
		reg_archivo = record
			arch:archivo;
			pos:integer;  //para indicar que posicion actual del archivo
		end;
		apersonas = record
			ra:reg_archivo;
			lib:libres;
            p:tpersona;
		end;
  //De los registros:
  	procedure Consultar_nombre(var nom:String; P:tpersona);                 //pone en nom el nombre del registro P;
   	procedure Consultar_apellido(var ape:String; P:tpersona);               //pone en ape el apellido del registro P;
  	function Consultar_dni(P:tpersona):Longword;                                //devuelve el dni del registro P;
   	function Consultar_fechanac(P:tpersona):Longword;                           //devuelve la fecha de nacimiento del registro P;
  //De los archivos:
    procedure CrearArchivo(var A:apersonas; nombre:String; nomlib:String);                 //Inicializa y asigna los archivos, recibe el nombre del archivo de registros;
    procedure Abrir (var A:apersonas; nomarch:String; nomlib:String);
    procedure DevolverPersona (A:apersonas; var P:tpersona);
	procedure Cargar(var A:apersonas);                                          //Carga un nuevo registro al final del archivo de registros;
	procedure Primero (var A:apersonas; var exito:boolean);                     //Se posiciona en el primer registro del archivo y devuelve si se pudo realizar o no;
	procedure Siguiente (var A:apersonas; var exito:boolean);                   //Se posiciona en el siguiente registro válido del archivo y devuelve si lo pudo hacer;
	procedure Recuperar (var A:apersonas; dni:Longword; var exito:boolean);     //Se posiciona en el registro con el mismo dni y devuelve si lo pudo realizar;
	procedure Exportar (var A:apersonas; var arch:Text; nombreTxt:String);  //Exporta el archivo de registros a un nuevo archivo de texto del cual recibe el nombre;
	procedure Insertar (var A:apersonas; var exito:boolean);                    //Inserta un nuevo registro en algun espacio libre o al final y devuelve si lo pudo hacer;
	procedure Eliminar (var A:apersonas; dni:Longword; var exito:boolean);      //Elimina el registro con dni indicado y devuelve si lo pudo hacer;
	procedure Modificar (var A:apersonas; nom:String; ape:String; dni:Longword; fecnac:Longword; var exito:boolean);    //Modifica el registro con mismo dni y devuelve si lo pudo hacer;
	procedure Respaldar (var A:apersonas);                                      //Crea una nueva versión del archivo sin espacios libres;
	procedure Cerrar (var A:apersonas);

implementation
    procedure Crear(nom:String; ape:String; dnil:Longword; fecnac:Longword; var T:tpersona); // proxlibre??
	begin
		with T do
		begin
			valido:=true;
			DNI:= dnil;
			Apellido:= ape;
			Nombre:= nom;
			FechaNac:= fecnac;
		end;
	end;
    procedure verActual(var A:apersonas; var P:tpersona);
    begin
         P:=A.p;
    end;
	procedure Consultar_nombre(var nom:String; P:tpersona);
	begin
		if (P.valido) then
			nom:=P.Nombre;
	end;
	procedure Consultar_apellido(var ape:String; P:tpersona);
	begin
		if (P.valido) then
			ape:= P.Apellido;
	end;
	function Consultar_dni(P:tpersona):Longword;
	begin
		if (P.valido) then
			Consultar_dni:= P.DNI;
	end;
	function Consultar_fechanac(P:tpersona):Longword;
	begin
		if (P.valido) then
			Consultar_fechanac:= P.FechaNac;
	end;
	procedure CrearArchivo(var A:apersonas; nombre:String; nomlib:String);
	begin
		assign(A.ra.arch, nombre);
		assign(A.lib, nomlib);
		rewrite(A.ra.arch);
		rewrite(A.lib);
		A.ra.pos:= 0;
	end;
    procedure Abrir(var A:apersonas; nomarch:String; nomlib:String);
    begin
		assign(A.ra.arch, nomarch);
		assign(A.lib, nomlib);
		reset(A.ra.arch);
		reset(A.lib);
		A.ra.pos:=0;
	end;
    procedure CargarPersona(var A:apersonas);
    var
	   nombre, apellido: String;
	   dni, fechanacimiento: Longword;
    begin
	   write('Escriba su nombre: ');
	   readln(nombre);
	   write('Escriba su apellido: ');
	   readln(apellido);
	   write('Escriba su dni: ');
       readln(dni);
	   write('Escriba su fecha de nacimiento: ');
       readln(fechanacimiento);
	   Crear(nombre, apellido, dni, fechanacimiento, A.p);
    end;
	procedure Cargar(var A:apersonas);
	begin
        CargarPersona(A);
		Seek(A.ra.arch,(FileSize(A.ra.arch)+1));  {Se posiciona al final}
		write(A.ra.arch,A.p);
	end;
    procedure DevolverPersona (A:apersonas; var P:tpersona);
    begin
         P:= A.p;
    end;
	procedure Primero (var A:apersonas; var exito:boolean);
	begin
		seek(A.ra.arch, 1);
		exito:=false;
		if (not EoF(A.ra.arch)) then begin
			read(A.ra.arch, A.p);
			if (A.p.valido) then exito:=true;
			end;	
	end;
	procedure Siguiente (var A:apersonas; var exito:boolean);
	begin
		exito:=false;
		while((not EoF(A.ra.arch)) and (not exito)) do begin
			read(A.ra.arch, A.p);
			A.ra.pos:=A.ra.pos+1;
			if (A.p.valido) then exito:=true;
            end;
	end;
	procedure Recuperar (var A:apersonas; dni:Longword; var exito:boolean);
	begin
		exito:= false;
		Seek(A.ra.arch,0);
		while ((not EoF(A.ra.arch)) and (not exito)) do
		begin
			read(A.ra.arch,A.p);
			if ((A.p.valido) and (Consultar_dni(A.p) = dni)) then
				exito:=true;
		end;
	end;
	procedure Exportar (var A:apersonas; var arch:Text; nombreTxt:String);
	var
		cadena: String;
        nom, ape:String;
	begin
		assign(arch, nombreTxt);
		rewrite(arch);
		Seek(A.ra.arch,0);
		A.ra.pos:= 0;
		while (not EoF(A.ra.arch)) do
		begin
			read(A.ra.arch,A.p);
			A.ra.pos:= A.ra.pos +1;
			if (A.p.valido)then //solo escribe en el .txt si es un registro vÃ¡lido
			begin
                Consultar_nombre(nom, A.p);
                Consultar_apellido(ape, A.p);
                cadena:= 'Nombre: '+nom+ ' Apellido: '+ ape+ ' DNI: '+IntToStr(Consultar_dni(A.p))+ ' Fecha de nacimiento: '+IntToStr(Consultar_fechanac(A.p));
				writeln(arch, cadena);
			end;
		end;
		close(arch);
	end;
	procedure agregar(var A:apersonas); //proceso privado
	var
		pos:integer;
	begin
		if (FileSize(A.lib)>0) then 
		begin
			Seek(A.lib, FileSize(A.lib)-1); //#Hay que ver si FileSize(A.lib) lleva a la posicion de EoF o a la del Ãºltimo elemento
			read(A.lib, pos);
			Seek(A.ra.arch,pos); //vamos a la posicion libre
			write(A.ra.arch,A.p);
            seek(A.lib, FileSize(A.lib)-1);
			Truncate(A.lib);
		end
		else Cargar(A);
	end;
	procedure Insertar (var A:apersonas; var exito:boolean);
	var
		encontro:boolean;
		T:tpersona;
	begin
        CargarPersona(A); //el usuario ingresa los datos de la persona y la pone en A.p
		T:=A.p;
		Recuperar(A, Consultar_dni(A.p), encontro);
		A.p:=T;
		Seek(A.ra.arch,0);
		if (not encontro) then //no se encontro por lo tanto debe agregarse
		begin
			agregar(A); //agregar en el primer lugar liberado o al final del archivo
			exito:=true;
		end
		else exito:=false;
	end;
	procedure Eliminar (var A:apersonas; dni:Longword; var exito:boolean); //no se hace una eliminacion logica ni fisica, solo se pone la posicion que se desea eliminar en el archivo 'A.lib'
	var
		encontro: boolean;
	begin
		Recuperar(A, dni, encontro);
		if (encontro) then begin
			A.ra.pos:=FilePos(A.ra.arch)-1;
			A.p.valido:=false;
			seek(A.ra.arch, A.ra.pos);
			write(A.ra.arch, A.p);
			seek(A.lib, FileSize(A.lib));
			write(A.lib, A.ra.pos);
			exito:=true;
			end
		else exito:=false;
	end;
	procedure Modificar (var A:apersonas; nom:String; ape:String; dni:Longword; fecnac:Longword; var exito:boolean);
	var
		encontro:boolean;
	begin
		Seek(A.ra.arch,0);
		Recuperar(A, dni, encontro);
		if (encontro) then //si se encontro la persona a sobrescribir
		begin
			Crear(nom, ape, dni, fecnac, A.p);
			Seek(A.ra.arch, (FilePos(A.ra.arch)-1)); //vuelve a la posicion a sobrescribir
			write(A.ra.arch, A.p);
		end;
		exito:= encontro;
	end;
	procedure Respaldar (var A:apersonas);
	var
		nuevo:archivo;
		exito:boolean;
	begin
		Seek(A.ra.arch,0);
		assign(nuevo, 'archivoRespaldado');
		rewrite(nuevo);
		while (not EoF(A.ra.arch)) do begin
			Siguiente(A, exito);
			if (exito) then write(nuevo, A.p);
        end;
		//close(nuevo);
		//close(A.ra.arch);
		A.ra.arch:= nuevo;   //# Esto no sÃ© si se puede hacer
	end;
	procedure Cerrar(var A:apersonas);
	begin
		close(A.ra.arch);
		close(A.lib);
	end;
End.
