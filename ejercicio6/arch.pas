UNIT arch;
interface
	uses persona, sysutils;
	type

		archivo = File of tpersona;
		libres = File of integer;
		reg_archivo = record
			arch:archivo;
			pos:integer;  //para indicar que posicion actual del archivo
		end;
		apersonas = record
			ra:reg_archivo;
			lib:libres;
		end;
    procedure CrearArchivo(var A:apersonas; nombre:string[20]);
	procedure Cargar(T:tpersona; var A:apersonas); //ver que pasa con proxlibre
	procedure Primero (var T:tpersona; A:apersonas; var exito:boolean);
	procedure Siguiente (var P:tpersona; A:apersonas; var exito:boolean);
	procedure Recuperar (A:apersonas; var P:tpersona; dni:Longword; var exito:boolean);
	procedure Exportar (A:apersonas; var arch:Text; nombreTxt:String[20]);
	procedure Insertar (var A:apersonas; P:tpersona; var exito:boolean);
	procedure Eliminar (dni:Longword; var A:apersonas; var exito:boolean);
	procedure Modificar (var A:apersonas; nom:String[20]; ape:String[20]; dni:Longword; fecnac:Longword; var exito:boolean);
	procedure Respaldar (var A:apersonas);

implementation

	procedure CrearArchivo(var A:apersonas; nombre:string[20]);
	begin
		assign(A.ra.arch, nombre);
		assign(A.lib, 'libres');
		rewrite(A.ra.arch);
		rewrite(A.lib);
		A.ra.pos:= 0;
		close(A.lib);
		close(A.ra.arch);
	end;	
	procedure Cargar(T:tpersona; var A:apersonas);
	begin
		reset(A.ra.arch);
		Seek(A.ra.arch,(FileSize(A.ra.arch)+1));  {Se posiciona al final}
		write(A.ra.arch,T);	
		close(A.ra.arch);	
	end;
	procedure resetearArchivos(var A:apersonas); //procedimiento privado
	begin
		reset(A.ra.arch);
		A.ra.pos:= 0;
		reset(A.lib);
	end;
	procedure Primero (var T:tpersona; A:apersonas; var exito:boolean);
	begin
		resetearArchivos(A);
		exito:=false;
		if (not EoF(A.ra.arch)) then begin
			read(A.ra.arch, T);
			if (T.valido) then exito:=true;
			end;	
	end;
	procedure Siguiente (var P:tpersona; A:apersonas; var exito:boolean); //ver si es necesario un proceso leer o alcanza con el read
	begin
		exito:=false;
		while((not EoF(A.ra.arch)) and (not exito)) do begin
			read(A.ra.arch, P);
			A.ra.pos:=A.ra.pos+1;
			if (P.valido) then exito:=true;
            end;
	end;
	procedure Recuperar (A:apersonas; var P:tpersona; dni:Longword; var exito:boolean);
	begin
		exito:= false;
		resetearArchivos(A);
		while ((not EoF(A.ra.arch)) and (not exito)) do
		begin
			read(A.ra.arch,P);
			if (Consultar_dni(P) = dni) then
				exito:=true;
		end;
	end;
	procedure Exportar (A:apersonas; var arch:Text; nombreTxt:String[20]);
	var
		P: tpersona; //para leer registros
		cadena: String;
        nom, ape:String[20];
	begin
		assign(arch, nombreTxt);
		rewrite(arch);
		resetearArchivos(A);
		while (not EoF(A.ra.arch)) do
		begin
			read(A.ra.arch,P);
			A.ra.pos:= A.ra.pos +1;
			if (P.valido)then //solo escribe en el .txt si es un registro válido
			begin
                Consultar_nombre(nom, P);
                Consultar_apellido(ape, P);
                cadena:= 'Nombre: '+nom+ ' Apellido: '+ ape+ ' DNI: '+ IntToStr(Consultar_dni(P))+ ' Fecha de nacimiento: '+ IntToStr(Consultar_fechanac(P));
				writeln(arch, cadena);
			end;
		end;
		close(arch);
		close(A.lib);
		close(A.ra.arch);
	end;
	procedure agregar(var A:apersonas; P:tpersona); //proceso privado
	var
		pos:integer;
	begin
		if (FileSize(A.lib)>0) then 
		begin
			Seek(A.lib, FileSize(A.lib)); //#Hay que ver si FileSize(A.lib) lleva a la posicion de EoF o a la del último elemento
			read(A.lib, pos);
			Seek(A.ra.arch,pos); //vamos a la posicion libre
			write(A.ra.arch,P);
            seek(A.lib, FileSize(A.lib)-1);
			Truncate(A.lib);
		end
		else Cargar(P, A);		
	end;
	procedure Insertar (var A:apersonas; P:tpersona; var exito:boolean);
	var
		encontro:boolean; T:tpersona;
	begin
		Recuperar(A, T, Consultar_dni(P), encontro);
		resetearArchivos(A);
		if (not encontro) then //no se encontro por lo tanto debe agregarse
		begin
			agregar(A,P); //agregar en el primer lugar liberado o al final del archivo
			exito:=true;
		end
		else exito:=false;
		close(A.lib);
		close(A.ra.arch);
	end;
	procedure Eliminar (dni:Longword; var A:apersonas; var exito:boolean); //no se hace una eliminacion logica ni fisica, solo se pone la posicion que se desea eliminar en el archivo 'A.lib'
	var
		encontro: boolean;
		P: tpersona;
	begin
		Recuperar(A, P, dni, encontro);
		if (encontro) then begin
			A.ra.pos:=FilePos(A.ra.arch)-1;
			P.valido:=false;
			seek(A.ra.arch, A.ra.pos);
			write(A.ra.arch, P);
			seek(A.lib, FileSize(A.lib)+1);
			write(A.lib, A.ra.pos);
			exito:=true;
			end
		else exito:=false;
		close(A.lib);
		close(A.ra.arch);

	end;
	procedure Modificar (var A:apersonas; nom:String[20]; ape:String[20]; dni:Longword; fecnac:Longword; var exito:boolean);
	var
		P:tpersona;
		encontro:boolean;
	begin
		resetearArchivos(A);
		Recuperar(A, P, dni, encontro);
		if (encontro) then //si se encontro la persona a sobrescribir
		begin
			Crear(nom, ape, dni, fecnac, P);
			Seek(A.ra.arch, (FilePos(A.ra.arch)-1)); //vuelve a la posicion a sobrescribir
			write(A.ra.arch,P);
		end;
		exito:= encontro;
		close(A.lib);
		close(A.ra.arch);
	end;
	procedure Respaldar (var A:apersonas);
	var
		nuevo:archivo;
		P:tpersona;
		exito:boolean;
	begin
		resetearArchivos(A);
		assign(nuevo, 'archivoRespaldado');
		rewrite(nuevo);
		while (not EoF(A.ra.arch)) do begin
			Siguiente(P, A, exito);
			if (exito) then write(nuevo, P);
        end;
		close(nuevo);
		close(A.ra.arch);
		A.ra.arch:= nuevo;   //# Esto no sé si se puede hacer
	end;
End.
