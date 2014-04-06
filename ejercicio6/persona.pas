UNIT persona;
interface
	type
		tpersona = Packed Record
          case valido: Boolean of True:(
                DNI:Longword;
				Apellido:String[20];
				Nombre:String[20];
				FechaNac:Longword);
		end;
	procedure Crear(nom:String[20]; ape:String[20]; dnil:Longword; fecnac:Longword; var T:tpersona);
	procedure Modificar_nombre(nom:String[20]; var T:tpersona);
	procedure Modificar_apellido(ape:String[20]; var T:tpersona);
	procedure Modificar_dni(dni:Longword; var T:tpersona);
	procedure Modificar_fechanac(fc:Longword; var T:tpersona);
	procedure Consultar_nombre(var nom:String[20]; T:tpersona);
	procedure Consultar_apellido(var ape:String[20]; T:tpersona);
	function Consultar_dni(T:tpersona):Longword;
	function Consultar_fechanac(T:tpersona):Longword;
implementation
	procedure Crear(nom:String[20]; ape:String[20]; dnil:Longword; fecnac:Longword; var T:tpersona); // proxlibre??
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
	procedure Modificar_nombre(nom:String[20]; var T:tpersona);
	begin
		if (T.valido) then
			T.Nombre:= nom;
	end;
	procedure Modificar_apellido(ape:String[20]; var T:tpersona);
	begin
		if (T.valido) then
			T.Apellido:= ape;
	end;
	procedure Modificar_dni(dni:Longword; var T:tpersona);
	begin
		if (T.valido) then
			T.DNI:= dni;
	end;
	procedure Modificar_fechanac(fc:Longword; var T:tpersona);
	begin
		if (T.valido) then
			T.FechaNac:= fc;
	end;
	procedure Consultar_nombre(var nom:String[20]; T:tpersona);
	begin
		if (T.valido) then
			nom:= T.Nombre;
	end;
	procedure Consultar_apellido(var ape:String[20]; T:tpersona);
	begin
		if (T.valido) then
			ape:= T.Apellido;
	end;
	function Consultar_dni(T:tpersona):Longword;
	begin
		if (T.valido) then
			Consultar_dni:= T.DNI;
	end;
	function Consultar_fechanac(T:tpersona):Longword;
	begin
		if (T.valido) then
			Consultar_fechanac:= T.FechaNac;
	end;
End.
