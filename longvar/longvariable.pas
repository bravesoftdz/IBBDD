UNIT longvariable;
INTERFACE
         Const
              LongBloque = 1024;
              NoHay: tNroBloque = High(tNroBloque);
              FIN_REGISTRO = '@';
              FIN_CAMPO = '#';
              FIN_BLOQUE = '*';
         Type
             tNroBloque = Word;
             tBloque = Array[1..LongBloque] of Byte;
             abPersonas = File;
             tEstado = (C, E, LE);
             tPersona = Record
                      DNI: Longword;
                      Apellido: String[20];
                      Nombres: String[20];
                      FechaNac: Longword;
             end;
             ctlPersonas = Record
                         estado: tEstado;
                         arch: abPersonas;
                         b: tBloque;
                         ib: Word;
                         libres: File of Word;
                         libre: Word;
                         pe: Array[1..60] of Byte;
                         lpe: Byte;
                         p: tPersona;
             end;

             Procedure Crear(var a: ctlPersonas);
             Procedure Abrir(var a: ctlPersonas; modo: tEstado);
             Procedure Cerrar(var a: ctlPersonas);
             Function Libre(var a: ctlPersonas): tNroBloque;
             Procedure Cargar(var a:ctlPersonas);

IMPLEMENTATION

              Procedure Crear(var a: ctlPersonas);
              begin
                   Rewrite(a.arch, LongBloque);
                   Rewrite(a.libres);
                   a.estado:=E;
                   a.ib:=1;
              end;
 
              Procedure Abrir(var a: ctlPersonas; modo: tEstado);
              begin
                   Reset(a.arch, LongBloque); Reset(a.libres);
                   a.estado:=modo;
                   if (modo=E) then
                   begin
                        Seek(a.arch, FileSize(a.arch)-1);
                        BlockRead(a.arch, a.b, 1);
                        Seek(a.libres, FileSize(a.libres)-1);
                        Read(a.libres, a.libre);
                        ib:=LongBloque – a.libre+1;
                   end;
              end;
 
              Procedure Cerrar(var a: ctlPersonas);
              begin
                   if (modo=E) then
                   begin
                        BlockWrite(a.arch, a.b, 1);
                        Write(a.libres, alibre);
                   end;
                   Close(a.arch);
                   Close(a.libres);
                   a.Estado:=C;
              end;
 
              Function Libre(var a: ctlPersonas): tNroBloque;
              var
                 encontrado: Boolean = False;
              begin
                   Seek(a.libres, 0);
                   while (not encontrado) and (FilePos(a.libres)<FileSize(a.libres)) do
                   begin
                        Read(a.libres, a.libre);
                        encontrado:=(a.libre>=a.lpe);
                   end;
                   if encontrado then Libre:=FilePos(a.libres)-1);
                   else Libre:= NoHay;
              end;

              Function UltimoBloqueLibre(a:ctlPersonas):boolean;
              begin
                   Seek(a.libres, (FileSize(a.libres)-1));
                   Read(a.libres, a.libre);
                   Seek(a.libres,0);
                   UltimoBloqueLibre:= (a.libre>=a.lpe);
              end;

              Procedure Empaquetar (var a:ctlPersonas);
              var
                 sx: String;
                 i: integer;
              begin
                   i:=1;
                   Str(a.p.dni, sx);
                   sx:=sx+FIN_CAMPO;
                   Move(sx[1], a.pe[i], Length(sx));
                   Inc(i, Length(sx));
                   sx:=a.p.Apellido+FIN_CAMPO;
                   Move(sx[1], a.pe[i], Length(sx));
                   Inc(i, Length(sx));
                   sx:=a.p.Nombres+FIN_CAMPO;
                   Move(sx[1], a.pe[i], Length(sx));
                   Inc(i, Length(sx));
                   Str(a.p.FechaNac, a.p.FechaNac);
                   sx:=sx+FIN_REGISTRO;
                   Move(sx[1], a.pe[i], Length(sx));
                   Inc(i, Length(sx));
                   a.ib := a.ib + i;
              end;

              Procedure EscribirEnBloqueUltimo(var a:ctlPersonas);    // devuelve en a.b el bloque listo para ser escrito
              var
                 i: integer;
              begin
                   i:= 1;
                   act:= 1;
                   while (a.b[i] <> FIN_BLOQUE) do            i:= i+1;	// aca tendria que copiar tambien las marcas
                   while (a.pe[act] <> FIN_REGISTRO) do
                   begin
                        Move(a.pe[act], a.b[i], 1); // mueve el caracter de a.pe[act] a a.b[i] (un solo caracter)
                        i:= i+1;
                        act:= act+1;
                   end;
              end;

              Procedure EscribirEnBloqueNuevo(var a:ctlPersonas);
              begin
                   i:= 1;
                   while(a.pe[i] <> FIN_REGISTRO) do     //aca conviene que despues del while se ponga la marca FIN_BLOQUE
                   begin
                        Move(a.pe[i], a.b[i], 1);
                        i:= i+1;
                   end;
              end;

              Procedure Cargar(var a:ctlPersonas);
              begin
                   if (a.estado <> LE) then    a.estado:= LE;
                   Seek(a.arch, (FileSize(a.arch)-1));
                   ReadBlock(a.arch, a.b, 1);
                   Empaquetar(a);
                   if (UltimoBloqueLibre(a)) then
                   begin
                        Seek(a.arch, (FilePos(a.arch)-1)); //vuelve al ultimo bloque a seguir escribiendo
                        EscribirEnBloqueUltimo(a);
                   end;
                   else EscribirEnBloqueNuevo(a);
                   BlockWrite(a.arch, a.b, 1);
              end;
              
              Procedure Eliminar(var a:ctlPersonas; dni:Longword; var exito:boolean);
              var
				sx:String;
				b:boolean;
				i, act:word;
              begin
				b:=false;
				Str(dni, sx);
				while ((not EOF(a.arch)) and (not b)) do begin					// recorre el archivo buscando el bloque que contiene 'dni'
					BlockRead(a.arch, a.b, 1);
					a.ib:=1;
					while ((a.b[a.ib] <> FIN_BLOQUE) and (not b)) do begin			// recorre el bloque buscando un dni igual
						i:=1;
						while ((a.b[a.ib] <> FIN_CAMPO) and (a.b[a.ib] = sx[i])) do begin   // realiza la comparacion
							i:=i+1;
							a.ib:=a.ib+1;
						end;
						if (a.b[a.ib] = FIN_CAMPO) then b:=true
						else begin
							while (a.b[a.ib] <> FIN_REGISTRO) do a.ib:=a.ib+1;			// si no lo encuentra se ubica en el registro siguiente
							a.ib:=a.ib+1;
						end;
					end;
				end;
				if (b) then begin
					act:=a.ib;					// 'act' es el indice de las posiciones a reacomodar
					a.ib:=a.ib-Length(sx)-1;		// 'a.ib' es el indice de la posicion donde empieza el registro a eliminar
					repeat act:=act+1; until (a.b[act] <> FIN_REGISTRO);
					Move (a.b[act], a.b[a.ib], LongBloque-act+1);			// se realiza el corrimiento solapando el registro a borrar
					while (a.b[act] <> FIN_BLOQUE) do act:=act+1;
					BlockWrite(a.arch, a.b, 1);					// se escribe la modificacion en el archivo
					seek(a.libres, FilePos(a.arch)-1);
					read(a.libres, a.libre);
					a.libre:=a.libre+LongBloque-act;		// 'act' se utiliza para calcular la cantidad de bytes libres
					seek(a.libres, FilePos(a.libres)-1);
					write(a.libres, a.libre);				// se actualiza el archivo de libres
				end;
				exito := b;
              end;


			Procedure Recuperar(var a:ctlPersonas; dni:Longword; var exito:boolean);
              var
				sx:String;
				b:boolean;
				i, t:word;
              begin
				b:=false;
				Str(dni, sx);
				while ((not EOF(a.arch)) and (not b)) do begin					// recorre el archivo buscando el bloque que contiene 'dni'
					BlockRead(a.arch, a.b, 1);
					a.ib:=1;
					while ((a.b[a.ib] <> FIN_BLOQUE) and (not b)) do begin			// recorre el bloque buscando un dni igual
						i:=1;
						while ((a.b[a.ib] <> FIN_CAMPO) and (a.b[a.ib] = sx[i])) do begin   // realiza la comparacion
							i:=i+1;
							a.ib:=a.ib+1;
						end;
						if (a.b[a.ib] = FIN_CAMPO) then b:=true
						else begin
							while (a.b[a.ib] <> FIN_REGISTRO) do a.ib:=a.ib+1;			// si no lo encuentra se ubica en el registro siguiente
							a.ib:=a.ib+1;
						end;
					end;
				end;
				if (b) then begin
					p.DNI:=dni;
					i := a.ib;
					t:=0;
					while (a.b[a.ib] <> FIN_CAMPO) do begin
						a.ib:=a.ib+1;
						t:=t+1;
					end;
					Move(a.b[i], a.p.Apellido[1], t);
					a.ib:=a.ib+1;
					i:=a.ib;
					t:=0;
					while (a.b[a.ib] <> FIN_CAMPO) do begin
						a.ib:=a.ib+1;
						t:=t+1;
					end;
					Move(a.b[i], a.p.Nombres[1], t);
					a.ib:=a.ib+1;
					i:=a.ib;
					t:=0;
					while (a.b[a.ib] <> FIN_REGISTRO) do begin
						a.ib:=a.ib+1;
						t:=t+1;
					end;
					Move(a.b[i], sx[1], t);
					{ Aca habria que convertir 'sx' a Longword pasandolo a 'a.p.FechaNac' }
				end;
				exito:=b;
              end;

