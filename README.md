# COBRO FLOTANTE

Pantalla de cobro para el mostrador. El vendedor carga el importe en un ícono flotante
y el cliente, en un segundo monitor, ve el total y el alias para transferir — o las
formas de pago con los valores ya calculados (débito, efectivo con descuento, cuotas).
Al cobrar, un cartel de **PAGO RECIBIDO**.

Acá se publican los ejecutables. El código es privado.

**Windows 10 u 11.** No hace falta instalar Python ni nada más.

---

## Instalar

### 1. Agregá la excepción del antivirus

Antes de bajar nada, agregá `C:\cobro-flotante` a las exclusiones de tu antivirus
(en Windows Defender: *Seguridad de Windows → Protección antivirus → Administrar
la configuración → Exclusiones → Agregar una carpeta*).

No es un capricho: el programa se actualiza solo, y un programa que descarga un
ejecutable y reemplaza otro es exactamente lo que hace un virus. Los falsos positivos
son probables.

### 2. Bajá el instalador

**[⬇ CobroFlotante-Setup.exe](https://github.com/GibelloE/cobro-flotante-releases/releases/latest/download/CobroFlotante-Setup.exe)**
— siempre es la última versión.

### 3. Doble clic

Va a aparecer **"Windows protegió tu PC"**. Es SmartScreen avisando que el programa no
tiene firma digital (las firmas se compran). **Más información → Ejecutar de todas
formas.** Pasa una sola vez.

Después, *Siguiente* hasta el final: se instala en `C:\cobro-flotante` sin pedir
permisos de administrador, te ofrece un acceso directo en el escritorio, y al terminar
abre el programa.

Listo: tenés que ver un círculo flotante en pantalla, que se arrastra a donde quieras.

> **Si ya estaba instalado**, podés correr el setup de nuevo encima: si el programa está
> abierto te pregunta antes de cerrarlo, y tu configuración no se toca.

<details>
<summary>Otra forma: el script de PowerShell (sin internet, o si el setup no te deja)</summary>

Entrá a [`instalar.ps1`](instalar.ps1), tocá **Download raw file**, y en la carpeta donde
lo guardaste abrí PowerShell (clic derecho con **Shift** → *Abrir la ventana de
PowerShell aquí*):

```powershell
powershell -ExecutionPolicy Bypass -File instalar.ps1
```

Baja la última versión, **verifica que sea exactamente la publicada** (SHA-256), deja el
acceso directo y abre el programa. Sin internet, con el `.exe` y su `.sha256` en un
pendrive: `-Desde D:\CobroFlotante.exe`.
</details>

---

## Configurar

Clic derecho sobre el círculo → **Configuración...** → te pide una contraseña (te la
paso por privado).

Lo único importante para empezar es la pestaña **PANTALLA DEL CLIENTE → Monitor**:
*Detectar monitores conectados* → elegí el monitor del cliente → *Usar este monitor*
→ *Probar visor de importe (TEST)* para ver cómo queda.

> **¿Tenés un solo monitor?** Podés probarlo igual: en esa misma pestaña, achicá el
> tamaño y movelo a un costado, así la pantalla del cliente no te tapa todo. Se cierra
> sola a los 60 segundos, o con el botón *Detener / Cerrar*.

En **COBRO** cargás el alias, el descuento por efectivo y los planes de cuotas.

La pestaña **MERCADO PAGO** viene apagada y así conviene dejarla: sirve para detectar
las transferencias en la cuenta del negocio, y necesita un token que no tenés.

Cuando termines: **Guardar y bloquear**.

---

## Cómo se usa

| | |
|---|---|
| **Clic** en el círculo | Abre el cuadro para tipear el importe |
| **Transferencia** | Muestra el importe y el alias en el otro monitor |
| **Formas de pago** | Muestra débito, efectivo con descuento y las cuotas |
| **Segundo clic** en el círculo | Cierra el cobro con el cartel de PAGO RECIBIDO |
| **Ctrl+Alt+C** | Abre el cuadro del importe sin usar el mouse (configurable) |
| **Ctrl+Alt+R** | Si perdiste el círculo fuera de pantalla, lo trae de vuelta |
| **Clic derecho → Salir** | Cierra el programa |

El borde del círculo funciona como reloj: muestra cuánto falta para que la pantalla del
cliente se cierre sola.

---

## Si estás probándolo: qué me sirve que me cuentes

Cualquier cosa rara, por chiquita que sea. Especialmente:

- Algo que se vea mal, se corte o quede tapado en cualquiera de las dos pantallas.
- Un clic o un atajo que no haga lo que esperabas.
- Que el programa se cierre solo, se cuelgue o tarde.
- Textos confusos, o algo que no se entienda sin que te lo explique.

**Si algo falla, mandame los archivos de `C:\cobro-flotante\data\logs\`.** Ahí el
programa anota los errores con su detalle técnico. No guardan datos personales ni
contraseñas.

Contame también en qué Windows estás y si tenés uno o dos monitores.

---

## Actualizar

Se actualiza solo. Cuando hay una versión nueva, al abrir el programa aparece un
renglón arriba del menú de clic derecho que lo avisa, y desde **Configuración →
ACERCA DE** el botón *Buscar actualizaciones* la baja, la verifica y la instala: el
programa se cierra y se abre solo, ya actualizado.

Tu configuración no se toca, y el ejecutable anterior queda guardado como
`CobroFlotante.exe.anterior` por si hay que volver atrás.

---

## Desinstalar

*Configuración de Windows → Aplicaciones → Aplicaciones instaladas → **Cobro Flotante**
→ Desinstalar.* Si el programa está abierto lo cierra, saca los accesos directos y el
inicio con Windows, y al final te pregunta si querés borrar también tu configuración
(la respuesta por defecto es no, por si lo volvés a instalar).

<details>
<summary>Si lo instalaste con el script de PowerShell</summary>

Ese no aparece en *Aplicaciones instaladas*. Se saca a mano:

1. Entrá a Configuración → **SISTEMA** y destildá *Iniciar con Windows*.
2. Cerrá el programa (clic derecho en el ícono → Salir).
3. Borrá la carpeta `C:\cobro-flotante` y el acceso directo del escritorio.

O más fácil: instalá el setup encima y desinstalá desde *Aplicaciones instaladas*.
</details>

---

Autoría: Emanuel Gibello · Licencia: pendiente de definir.
