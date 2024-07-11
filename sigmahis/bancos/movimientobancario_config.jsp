<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="cdo" scope="page" class="issi.admin.CommonDataObject" />
<%
/**
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
//if (!(SecMgr.checkAccess(session.getId(),"0") || SecMgr.checkAccess(session.getId(),"900103") || SecMgr.checkAccess(session.getId(),"900104"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
String sql = "";
String mode = request.getParameter("mode");
String cuentaCode = request.getParameter("cuenta");
String bancoCode = request.getParameter("banco");
String tipo_mov = request.getParameter("tipo_mov");
String fecha = request.getParameter("fecha");
String consecutivo = request.getParameter("consecutivo");
String filter = " and a.estado_cuenta = 'ACT'";
String fp  = request.getParameter("fp");

boolean viewMode = false;

if (cuentaCode == null) cuentaCode = "";
if (bancoCode == null) bancoCode = "";
if (tipo_mov == null) tipo_mov = "";
if (fecha == null) fecha = CmnMgr.getCurrentDate("dd/mm/yyyy");
if (consecutivo == null) consecutivo = "";
if (fp == null) fp = "";


if (mode == null) mode = "add";
if (mode.equalsIgnoreCase("view")) viewMode = true;

if (request.getMethod().equalsIgnoreCase("GET"))
{
	if (mode.equalsIgnoreCase("add"))
	{
		consecutivo = "0";
	}
	else
	{
	if (consecutivo == null) throw new Exception("El no es válido. Por favor intente nuevamente!");

	sql = "SELECT a.estado_trans as estado, a.observacion, a.monto, a.descripcion, b.descripcion as cuenta, c.nombre as banco, d.descripcion as tipo,a.tipo_movimiento,a.estado_dep ,a.num_documento, a.notas_debito, a.notas_credito, to_char(a.fecha_pago,'dd/mm/yyyy') as fecha_pago ,nvl(a.comprobante,'N') as comprobante,a.cta1,a.cta2,a.cta3,a.cta4,a.cta5,a.cta6, (select descripcion from tbl_con_catalogo_gral cg where cg.compania =a.compania and cg.cta1=a.cta1 and cg.cta2=a.cta2 and cg.cta3=a.cta3 and cg.cta4=a.cta4 and cg.cta5=a.cta5 and cg.cta6=a.cta6 ) as cuentaDes,a.caja  FROM tbl_con_movim_bancario a, tbl_con_cuenta_bancaria b, tbl_con_banco c, tbl_con_tipo_movimiento d WHERE a.cuenta_banco=b.cuenta_banco and a.banco=b.cod_banco and a.compania=b.compania and a.compania = c.compania and a.banco=c.cod_banco and a.tipo_movimiento = d.cod_transac and a.compania="+(String) session.getAttribute("_companyId")+" and a.tipo_movimiento='"+tipo_mov+"' and a.cuenta_banco='"+cuentaCode+"' and a.banco='"+bancoCode+"' and f_movimiento=to_date('"+fecha+"','dd/mm/yyyy') and consecutivo_ag="+consecutivo;
		cdo = SQLMgr.getData(sql);
		if(cdo.getColValue("comprobante").trim().equals("S"))viewMode = true;
	}
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<script language="javascript">
<%if (mode.equalsIgnoreCase("add")){%>
document.title="Registro Movimiento Bancario Agregar - "+document.title;
<%}else if (mode.equalsIgnoreCase("edit")){%>
document.title="Registro Movimiento Bancario Edición - "+document.title;
<%}%>
function addCuenta(){abrir_ventana1('../bancos/saldobank_cta_list.jsp?id=2&filter=<%=IBIZEscapeChars.forURL(filter)%>');}
function addTipo(){ abrir_ventana1('../bancos/movimientobancario_tipo_list.jsp');}
function setLado(){var tipo_nota_cr_db = document.getElementById('tipo_mov').value;var lado = getDBData('<%=request.getContextPath()%>','lado_transac','tbl_con_tipo_movimiento','cod_transac=\''+tipo_nota_cr_db+'\'','');document.getElementById('lado').value = lado;}
function setDoc(tipoDoc)
{
	var docs = tipoDoc;
	if(document.getElementById('estado_dep'))document.getElementById('estado_dep').style.display="";
	if(document.getElementById('num_documento'))document.getElementById('num_documento').style.display="";
	if(document.getElementById('notas_debito'))document.getElementById('notas_debito').style.display="";
	if(document.getElementById('notas_credito'))document.getElementById('notas_credito').style.display="";
	if(document.getElementById('notas_debito'))document.form1.notas_debito.disabled=true;
	if(document.getElementById('notas_credito'))document.form1.notas_credito.disabled=true;
	if(document.getElementById('btnCta'))document.form1.btnCta.disabled=true;	
	
	if(document.getElementById('cta1'))document.form1.cta1.value = "";
	if(document.getElementById('cta2'))document.form1.cta2.value = "";
	if(document.getElementById('cta3'))document.form1.cta3.value = "";
	if(document.getElementById('cta4'))document.form1.cta4.value = "";
	if(document.getElementById('cta5'))document.form1.cta5.value = "";
	if(document.getElementById('cta6'))document.form1.cta6.value = "";
	if(document.getElementById('cuentaDes'))document.form1.cuentaDes.value = "";
	
	setLado();
	//document.form1.lado.value = "DB";

	if(docs==3) {
		if(document.getElementById('notas_debito'))document.form1.notas_debito.disabled=false;
		if(document.getElementById('estado_dep'))document.getElementById('estado_dep').style.display="none";
		if(document.getElementById('num_documento'))document.getElementById('num_documento').style.display="none"
		if(document.getElementById('notas_credito'))document.getElementById('notas_credito').style.display="none";

		if(document.getElementById('estado_dep'))document.form1.estado_dep.value = "";
		if(document.getElementById('notas_credito'))document.form1.notas_credito.value = "";
		if(document.getElementById('num_documento'))document.form1.num_documento.value = "";
		//document.form1.lado.value = "DB";
	} else if(docs==2) {
		if(document.getElementById('notas_credito'))document.form1.notas_credito.disabled=false;
		if(document.getElementById('estado_dep'))document.getElementById('estado_dep').style.display="none";
		if(document.getElementById('num_documento'))document.getElementById('num_documento').style.display="none"
		if(document.getElementById('notas_debito'))document.getElementById('notas_debito').style.display="none";
		if(document.getElementById('notas_credito'))document.form1.notas_credito.readOnly=false;

		if(document.getElementById('estado_dep'))document.form1.estado_dep.value = "";
		if(document.getElementById('notas_debito'))document.form1.notas_debito.value = "";
		if(document.getElementById('num_documento'))document.form1.num_documento.value = "";
		//document.form1.lado.value = "CR";
	} else if(docs==1) {
		if(document.getElementById('btnCta'))document.form1.btnCta.disabled=false;		
		//if(document.getElementById('notas_credito'))document.form1.notas_credito.readOnly=false;	
		 
		 
	} else if(docs==-1) {//SALDO_INICIAL

		chkSaldoInicial();
		
		//document.form1.lado.value = "CR";
	}
}

function chkSaldoInicial(){
	if(document.form1.tipo_mov.value==-1) {//SALDO_INICIAL

		var banco = document.form1.bancoCode.value;
		var cuenta = document.form1.cuentaCode.value;
		if(document.getElementById('notas_credito'))document.form1.notas_credito.disabled=false;
		if(document.getElementById('estado_dep'))document.getElementById('estado_dep').style.display="none";
		if(document.getElementById('num_documento'))document.getElementById('num_documento').style.display="none"
		if(document.getElementById('notas_debito'))document.getElementById('notas_debito').style.display="none";
		if(document.getElementById('notas_credito'))document.getElementById('notas_credito').style.display="none";
		if(document.getElementById('notas_credito'))document.form1.notas_credito.readOnly=false;

		if(document.getElementById('estado_dep'))document.form1.estado_dep.value = "";
		if(document.getElementById('notas_debito'))document.form1.notas_debito.value = "";
		if(document.getElementById('notas_credito'))document.form1.notas_credito.value = "";
		if(document.getElementById('num_documento'))document.form1.num_documento.value = "";
		if(cuenta==''){
			alert('Seleccione Cuenta!');
			document.form1.tipo_mov.value='1';
		} else {
			var x = getDBData('<%=request.getContextPath()%>','1','tbl_con_movim_bancario','compania = <%=(String) session.getAttribute("_companyId")%> and tipo_movimiento = -1 and banco='+banco+' and cuenta_banco = \''+cuenta+'\' and estado_trans = \'C\'');
			if(x==1){
				alert('Ya existe un Saldo Inicial registrado a esta cuenta!');
				document.form1.tipo_mov.value='1';
				return false;
			} else return true;
		}
		
		//document.form1.lado.value = "CR";
	} else return true;
}

function dateCk()
{
    var size;
	var fechaValue;
	var banco;
	var cuenta;
	var msg = '';

	banco = document.form1.bancoCode.value;
	cuenta = document.form1.cuentaCode.value;
	fechaValue = document.form1.fecha.value;

	if(fechaValue == '')  msg = ' una Fecha ';
	if (msg == '')
	{
	  if(hasDBData('<%=request.getContextPath()%>','tbl_con_detalle_cuenta','compania=<%=(String) session.getAttribute("_companyId")%> and cod_banco=\''+banco+'\' and cuenta_banco=\''+cuenta+'\' and fecha_mes=to_number(to_char(to_date(\''+fechaValue+'\',\'dd/mm/yyyy\'),\'MM\')) and cpto_anio=TO_NUMBER(TO_CHAR(to_date(\''+fechaValue+'\',\'dd/mm/yyyy\'),\'YYYY\'))',''))
	{
		alert('**EL MES ESTA CONCILIADO CERRADO .....VERIFIQUE **!');
		//document.form1.fecha.value='';
		<%if(fp.trim().equals("sup")){%>return true;<%}else{%>return false;<%}%>
				
	}else return true;  /*else if(hasDBData('<%=request.getContextPath()%>','tbl_con_sb_saldos','compania=<%=(String) session.getAttribute("_companyId")%> and cod_banco=\''+banco+'\' and cuenta_banco=\''+cuenta+'\' and mes=to_number(to_char(to_date(\''+fechaValue+'\',\'dd/mm/yyyy\'),\'MM\')) and estatus=\'A\' and anio=to_number(to_char(to_date(\''+fechaValue+'\',\'dd/mm/yyyy\'),\'YYYY\'))',''))
	{
	cont++;
	} else alert('** EL MES NO ESTA ABIERTO....VERIFIQUE , DESEA CONTINUAR**!');*/
	} else alert('Seleccione '+msg);
}
function getCta(){abrir_ventana1('../common/search_catalogo_gral.jsp?fp=depBanco');}

function doAction(){setDoc(document.form1.tipo_mov.value);<%if(mode.trim().equals("edit")&&cdo.getColValue("comprobante").trim().equals("S")){%>CBMSG.warning('Esta transaccion tiene Comprobante generado. No puede modificar dicho registro. Registre Notas Debito/Credito segun sea el Caso. Ó Anule el Comprobante.!!');<%}%>}
function checkEstado(){var fecha = document.form1.fecha.value;var anio = fecha.substring(6,10);var mes = fecha.substring(3,5);var y=false;var x=false;if(anio!=''){  y=getEstadoAnio('<%=request.getContextPath()%>',<%=session.getAttribute("_companyId")%>,anio);if(y==true)x=getEstadoMes('<%=request.getContextPath()%>',<%=session.getAttribute("_companyId")%>,anio,mes);}if(y==false||x==false){document.form1.fecha.value='';return false;}else return true;}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction();">
<jsp:include page="../common/title.jsp" flush="true">
<jsp:param name="title" value="CONTABILIDAD - MANTENIMIENTO"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
  <tr>
    <td width="99%" class="TableBorder"><!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
      <table align="center" width="99%" cellpadding="0" cellspacing="1">
        <%fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
		<%=fb.formStart(true)%>
		<%=fb.hidden("mode",mode)%>
		<%=fb.hidden("fp",fp)%>

		<%
				fb.appendJsValidation("\n\tif (!chkSaldoInicial()) error++;\n");
				fb.appendJsValidation("\n\tif (!dateCk()) error++;\n");

				%>
        <tr>
          <td colspan="4">&nbsp;</td>
        </tr>
        <tr class="TextRow02">
          <td colspan="4">&nbsp;</td>
        </tr>
        <tr class="TextRow01">
          <td width="15%">Cuenta Bancaria</td>
          <td width="49%">
					<%=fb.textBox("cuentaCode",cuentaCode,true,false,true,5)%>
					<%=fb.textBox("cuenta",cdo.getColValue("cuenta"),true,false,true,48)%>
					<%=fb.button("btncuenta","...",true,!mode.equals("add"),null,null,"onClick=\"javascript:addCuenta()\"")%>
          </td>
          <td width="13%">Fecha</td>
          <td width="23%">
		  				<%String checkEstado = "javascript:dateCk();checkEstado();newHeight();";%>
		  				<jsp:include page="../common/calendar.jsp" flush="true">
						<jsp:param name="noOfDateTBox" value="1" />
						<jsp:param name="nameOfTBox1" value="fecha" />
						<jsp:param name="valueOfTBox1" value="<%=fecha%>" />
            			<jsp:param name="jsEvent" value="<%=checkEstado%>" />
						<jsp:param name="onChange" value="<%=checkEstado%>" />
						<jsp:param name="readonly" value="<%=(!mode.trim().equalsIgnoreCase("add"))?"y":"n"%>"/>
						</jsp:include>
          </td>
        </tr>
        <tr class="TextRow01">
          <td>Banco</td>
          <td>
					<%=fb.textBox("bancoCode",bancoCode,true,false,true,5)%>
					<%=fb.textBox("banco",cdo.getColValue("banco"),true,false,true,48)%>
          </td>
          <% if (mode.equalsIgnoreCase("edit")||mode.equalsIgnoreCase("view")) {
					%>
          <td>Fecha de Pago</td>
          <td><jsp:include page="../common/calendar.jsp" flush="true">
						<jsp:param name="noOfDateTBox" value="1" />
						<jsp:param name="nameOfTBox1" value="fechaPago" />
						<jsp:param name="valueOfTBox1" value="<%=cdo.getColValue("fecha_pago")%>" />
            <jsp:param name="readonly" value="<%=(mode.trim().equalsIgnoreCase("view"))?"y":"n"%>"/>
						</jsp:include></td>
          <%  } else {
					%>
          <td>&nbsp;</td>
          <td>&nbsp;</td>
          <% } %>
        </tr>
        <tr class="TextRow01">
          <td>Transacci&oacute;n</td>
          <td>
					<%=fb.select(ConMgr.getConnection(),"SELECT cod_transac, descripcion||' - '||cod_transac, cod_transac from tbl_con_tipo_movimiento  "+((mode.trim().equalsIgnoreCase("add"))?" where estado ='A' ":"")+" order by descripcion","tipo_mov",cdo.getColValue("tipo_movimiento"),false,(!mode.trim().equalsIgnoreCase("add")),0,"Text10",null,"onChange=\"javascript:setDoc(this.value)\"")%>
					</td>

          <td>Consecutivo</td>
          <td><%=fb.intBox("consecutivo",consecutivo,false,false,true,25)%></td>
        </tr>
		
		
		<tr class="TextRow01">
          <td> Cuenta Contable para Depositos (Efectivo y Cheque)</td>
          <td colspan="3"><%=fb.textBox("cta1",cdo.getColValue("cta1"),false,false,true,3,"Text10",null,"")%>
								<%=fb.textBox("cta2",cdo.getColValue("cta2"),false,false,true,2,"Text10",null,"")%>
								<%=fb.textBox("cta3",cdo.getColValue("cta3"),false,false,true,3,"Text10",null,"")%>
								<%=fb.textBox("cta4",cdo.getColValue("cta4"),false,false,true,3,"Text10",null,"")%>
								<%=fb.textBox("cta5",cdo.getColValue("cta5"),false,false,true,3,"Text10",null,"")%>
								<%=fb.textBox("cta6",cdo.getColValue("cta6"),false,false,true,3,"Text10",null,"")%>
                <%=fb.textBox("cuentaDes",cdo.getColValue("cuentaDes"),false,false,true,60,"Text10",null,"")%>
				<%=fb.button("btnCta","...",true,false,null,null,"onClick=\"javascript:getCta()\"")%></td>          
        </tr>
		
		
        <tr class="TextRow01">
          <td>Estado Transacci&oacute;n</td>
          <td><%=fb.select("estado","T=TRAMITADA,C=CONCILIADA,A=ANULADA",cdo.getColValue("estado"),false,viewMode,0,"")%></td>
          <% if(!tipo_mov.equals("1") && !mode.trim().equalsIgnoreCase("add")) { %>
          <td colspan="2">&nbsp;</td>
          <% } else { %>
          <td>Estado Deposito</td>
          <td><%=fb.select("estado_dep","DN=DEPOSITADO,DT=DEPOSITO EN TRANSITO",cdo.getColValue("estado_dep"),false,viewMode,0,"S")%></td>
          <% } %>
        </tr>
        <%=fb.hidden("notas_db",cdo.getColValue("notas_debito"))%> <%=fb.hidden("notas_cr",cdo.getColValue("notas_credito"))%> <%=fb.hidden("num_doc",cdo.getColValue("num_documento"))%> <%=fb.hidden("lado",cdo.getColValue("lado"))%>
        <tr class="TextRow01">
          <td>No. de Voucher</td>
          <td><% if((tipo_mov.equals("1") && !mode.trim().equalsIgnoreCase("add")) || (mode.trim().equalsIgnoreCase("add")) ) { %>
            <%=fb.textBox("num_documento",cdo.getColValue("num_documento"),false,false,viewMode,35,30)%>
            <% }  %>
          </td>
          <td>Monto</td>
          <td><%=fb.decPlusZeroBox("monto",cdo.getColValue("monto"),true,false,viewMode,25,12.2)%></td>
        </tr>
		<tr class="TextRow01" id="lb_ncdb">
          <td colspan="4"><font color="#FF0000">Las notas de Debitos Y Creditos Sin tipo no serán Mayorizadas. Deben Registrarlos manualmente.</font></td>
        </tr>
		
        <tr class="TextRow01">
          <td> Notas de Débito</td>
          <td><%=fb.select(ConMgr.getConnection(),"SELECT codigo, descripcion||' - '||codigo from tbl_con_tipo_nota_cr_db where tipo_mov = 'DB' and compania="+(String) session.getAttribute("_companyId")+"order by descripcion", "notas_debito", cdo.getColValue("notas_debito"), false, viewMode, 0, "Text10", null, "", "", "S")%>
            <%//=fb.select("notas_debito","GB=GASTO BANCARIO,T=TIMBRES,IS=INTERESES POR SOBREGIRO,CD=CHEQUES DEVUELTOS,CCD=CARGOS POR CHEQUES DEVUELTOS,DTC=DEVOLUCION TARJETAS DE CREDITO,DRL=DEPOSITOS POR REG. EN LIBROS,DC=DIFERENCIA DE COMISION,TCH=TRANSFERENCIA ACH,OT=OTROS DEBITOS",cdo.getColValue("notas_debito"),false,false,0,"S")%>
          </td>
          <td>Notas de Crédito</td>
          <td><%=fb.select(ConMgr.getConnection(),"SELECT codigo, descripcion||' - '||codigo from tbl_con_tipo_nota_cr_db where tipo_mov = 'CR' and compania="+(String) session.getAttribute("_companyId")+" order by descripcion", "notas_credito", cdo.getColValue("notas_credito"), false, viewMode, 0, "Text10", null, "", "", "S")%>
            <%//=fb.select("notas_credito","DCC=DIFERENCIA COMISION,DRLC=DEPOSITO POR REGISTRAR EN LIBRO,DTCC=DEV. DE TARJETAS DE CREDITO,OC=OTROS CREDITOS",cdo.getColValue("notas_credito"),false,false,0,"S")%></td>
        </tr>
        <tr class="TextRow01">
          <td>Observaci&oacute;n</td>
          <td colspan="3"><%=fb.textarea("observacion",cdo.getColValue("descripcion"),false,false,viewMode,45,5)%></td>
        </tr>
        <tr>
          <td colspan="4"><jsp:include page="../common/bitacora.jsp" flush="true">
            <jsp:param name="audTable" value="tbl_con_movim_bancario"></jsp:param>
            <jsp:param name="audFilter" value="<%="consecutivo_ag="+consecutivo+" and cuenta_banco='"+cuentaCode+"' and banco='"+bancoCode+"' and tipo_movimiento='"+tipo_mov+"' and trunc(f_movimiento)=to_date('"+fecha+"','dd/mm/yyyy') and compania="+(String) session.getAttribute("_companyId")%>"></jsp:param>
            </jsp:include>
          </td>
        </tr>
        <tr class="TextRow02">
          <td colspan="4" align="right"> Opciones de Guardar: <%=fb.radio("saveOption","N")%>Crear Otro <%=fb.radio("saveOption","O")%>Mantener Abierto <%=fb.radio("saveOption","C",true,false,false)%>Cerrar <%=fb.submit("save","Guardar",true,viewMode)%> <%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%> </td>
        </tr>
        <tr>
          <td colspan="4">&nbsp;</td>
        </tr>
		<%if(mode.trim().equals("add")){fb.appendJsValidation("if(!checkEstado()){error++;CBMSG.warning('Revise Fecha de la Transaccion!');}");}%>
        <%=fb.formEnd(true)%>
      </table>
      <!-- ================================   F O R M   E N D   H E R E   ================================ -->
    </td>
  </tr>
</table>
<%@ include file="../common/footer.jsp"%>
</body>
</html>
<%
}//GET
else
{
  String saveOption = request.getParameter("saveOption"); //N=Create New,O=Keep Open,C=Close
  cuentaCode = request.getParameter("cuentaCode");
  bancoCode = request.getParameter("bancoCode");
  tipo_mov = request.getParameter("tipo_mov");
  fecha = request.getParameter("fecha");
  consecutivo = request.getParameter("consecutivo");

  cdo = new CommonDataObject();

  cdo.setTableName("tbl_con_movim_bancario");
  cdo.addColValue("estado_trans",request.getParameter("estado"));
  cdo.addColValue("monto",request.getParameter("monto"));
 if (request.getParameter("observacion") != null)
  cdo.addColValue("descripcion",request.getParameter("observacion"));
   if (request.getParameter("num_documento") != null)
  cdo.addColValue("num_documento",request.getParameter("num_documento"));
  if (request.getParameter("notas_credito") != null)
  cdo.addColValue("notas_credito",request.getParameter("notas_credito"));
  else cdo.addColValue("notas_credito","");
  if (request.getParameter("notas_debito") != null)
  cdo.addColValue("notas_debito",request.getParameter("notas_debito"));
  else cdo.addColValue("notas_debito","");
   if (request.getParameter("estado_dep") != null)
  cdo.addColValue("estado_dep",request.getParameter("estado_dep"));
   if (request.getParameter("lado") != null) cdo.addColValue("lado",request.getParameter("lado"));
  //if (tipo_mov.equalsIgnoreCase("3")) cdo.addColValue("lado","CR");
  if (request.getParameter("fechaPago") != null)
  cdo.addColValue("fecha_pago",request.getParameter("fechaPago"));
  if (request.getParameter("estado") == "A")
  cdo.addColValue("f_anulacion",request.getParameter("fechaPago"));
    
  cdo.addColValue("cta1",request.getParameter("cta1"));
  cdo.addColValue("cta2",request.getParameter("cta2"));
  cdo.addColValue("cta3",request.getParameter("cta3"));
  cdo.addColValue("cta4",request.getParameter("cta4"));
  cdo.addColValue("cta5",request.getParameter("cta5"));
  cdo.addColValue("cta6",request.getParameter("cta6"));

  cdo.addColValue("usuario_modificacion",(String) session.getAttribute("_userName"));
  cdo.addColValue("fecha_modificacion",CmnMgr.getCurrentDate("dd/mm/yyyy hh24:mi:ss"));

    ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
	ConMgr.setAppCtx(ConMgr.AUDIT_NOTES,"fp="+fp);
  if (mode.equalsIgnoreCase("add"))
  {
    cdo.addColValue("usuario_creacion",(String) session.getAttribute("_userName"));
    cdo.addColValue("fecha_creacion","sysdate");

	cdo.addColValue("cuenta_banco",cuentaCode);
    cdo.addColValue("banco",bancoCode);
    cdo.addColValue("tipo_movimiento",tipo_mov);
	cdo.addColValue("f_movimiento",fecha);
    cdo.addColValue("compania",(String) session.getAttribute("_companyId"));
	cdo.setAutoIncWhereClause("compania="+(String) session.getAttribute("_companyId")+" and cuenta_banco='"+cuentaCode+"' and banco='"+bancoCode+"' and tipo_movimiento='"+tipo_mov+"' ");
	cdo.setAutoIncCol("consecutivo_ag");
	cdo.addPkColValue("consecutivo_ag","");

	SQLMgr.insert(cdo);
	consecutivo = SQLMgr.getPkColValue("consecutivo_ag");
  }
  else
  {

    cdo.setWhereClause("cuenta_banco='"+cuentaCode+"' and banco='"+bancoCode+"' and tipo_movimiento='"+tipo_mov+"' and compania="+(String) session.getAttribute("_companyId")+" and consecutivo_ag="+consecutivo);

	SQLMgr.update(cdo);
  }
	ConMgr.clearAppCtx(null);
%>
<html>
<head>
<script language="javascript" src="../build/web/js/capslock.js"></script>
<script language="javascript">
function closeWindow()
{
<%
if (SQLMgr.getErrCode().equals("1"))
{
%>
	alert('<%=SQLMgr.getErrMsg()%>');
<%
	if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/bancos/movimientobancario_list.jsp"))
	{
%>
	window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/bancos/movimientobancario_list.jsp")%>';
<%
	}
	else
	{
%>
	window.opener.location = '<%=request.getContextPath()%>/bancos/movimientobancario_list.jsp';
<%
	}

	if (saveOption.equalsIgnoreCase("N"))
	{
%>
	setTimeout('addMode()',500);
<%
	}
	else if (saveOption.equalsIgnoreCase("O"))
	{
%>
	setTimeout('editMode()',500);
<%
	}
	else if (saveOption.equalsIgnoreCase("C"))
	{
%>
	window.close();
<%
	}
} else throw new Exception(SQLMgr.getErrMsg());
%>
}

function addMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>';
}

function editMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?mode=edit&cuenta=<%=cuentaCode%>&banco=<%=bancoCode%>&tipo_mov=<%=tipo_mov%>&fecha=<%=fecha%>&consecutivo=<%=consecutivo%>&fp=<%=fp%>';
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>
