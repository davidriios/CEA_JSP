<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admision.CdcSolicitudDet"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" %>
<%@ page import="java.util.ResourceBundle" %>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="CdcSolMgr" scope="page" class="issi.admision.CdcSolicitudMgr" />
<%
/**
======================================================================================================================================================
FORMA								MENU																																																										NOMBRE EN FORMA
CDC100130						INVENTARIO\TRANSACCIONES\REQUISICION\MAT. PACIENTES - CONSULTA DE PRORAMAS QUIRURGICOS\SOLICITUD INSUMOS QUIRURGICOS		SOLICITUD PREVIA DE MAT. Y MED. PARA PACIENTES EN SALON DE OPERACIONES PENDIENTES.
======================================================================================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
//if (!(SecMgr.checkAccess(session.getId(),"0"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
CdcSolMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

SQL2BeanBuilder sbb = new SQL2BeanBuilder();
ArrayList al = new ArrayList();
CommonDataObject cdoP = new CommonDataObject();
String change = request.getParameter("change");
String key = "";
String sql = "";
String mode = request.getParameter("mode");
String fp = request.getParameter("fp");
String fg = request.getParameter("fg");
String type = request.getParameter("type");
String codCita = request.getParameter("codCita");
String fechaCita = request.getParameter("fechaCita");
String tipoSolicitud = request.getParameter("tipoSolicitud");
String secuencia = request.getParameter("secuencia");
String familia = request.getParameter("familia");
String clase = request.getParameter("clase");
String articulo = request.getParameter("articulo");
String paciente = request.getParameter("paciente");
String desc_articulo = request.getParameter("desc_articulo");
String almacenSOP = ResourceBundle.getBundle("issi").getString("almacenSOP");
boolean viewMode = false;
int lineNo = 0, contY = 0;

if (mode == null) mode = "add";
if(mode.equals("view")) viewMode = true;
if(fp==null) fp="";
if(type==null) type="";
if(codCita==null) codCita="";
if(fechaCita==null) fechaCita="";
if(tipoSolicitud==null) tipoSolicitud="";
if(secuencia==null) secuencia="";
if(familia==null) familia="";
if(clase==null) clase="";
if(articulo==null) articulo="";
if(paciente==null) paciente="";
if(desc_articulo==null) desc_articulo="";

String appendFilter = "";

if (request.getMethod().equalsIgnoreCase("GET"))
{
	sql = "select param_value valida_dsp from tbl_sec_comp_param where compania in(-1,"+(String) session.getAttribute("_companyId")+") and param_name = 'CHECK_DISP' ";
	cdoP = SQLMgr.getData(sql);
	if(cdoP ==null){cdoP =new CommonDataObject();cdoP.addColValue("valida_dsp","S");}

if(!fechaCita.equals("")) appendFilter = " and to_date(to_char(a.cita_fecha_reg, 'dd/mm/yyyy'), 'dd/mm/yyyy') = to_date('" + fechaCita + "', 'dd/mm/yyyy')";
if(!codCita.equals("")) appendFilter += " and a.cita_codigo = " + codCita + "";
if(fp.equals("quirofano")) appendFilter = "";
if(!secuencia.equals("")) appendFilter += " and a.secuencia = " + secuencia + "";
if(!familia.equals("")) appendFilter += " and a.art_familia = " + familia;
if(!clase.equals("")) appendFilter += " and a.art_clase = " + clase;
if(!articulo.equals("")) appendFilter += " and a.cod_articulo = " + articulo;
if(!paciente.equals("")) appendFilter += " and d.nombre_paciente like '%" + paciente + "%'";
if(!desc_articulo.equals("")) appendFilter += " and c.descripcion like '%" + desc_articulo + "%'";

		sql = "select a.cita_codigo, to_char(a.cita_fecha_reg, 'dd/mm/yyyy') cita_fecha_reg, a.secuencia, d.nombre_paciente, a.cod_articulo, a.art_familia, a.art_clase, nvl(a.cant_nuevo, 0) cant_nuevo, nvl(a.cant_devolucion, 0) cant_devolucion, nvl(a.cant_adicion, 0) cant_adicion, nvl(b.entrega, 0) entrega, nvl(b.adicion, 0) adicion, nvl(b.devolucion, 0) devolucion, c.descripcion, a.trx_hora, a.usuario_solicita, nvl(e.disponible, 0) disponible, a.trx_tipo,nvl(c.other3,'Y')afecta_inv from tbl_cdc_solicitud_trx a, tbl_cdc_solicitud_det b, tbl_inv_articulo c, tbl_cdc_cita d, tbl_inv_inventario e where a.cita_codigo = b.cita_codigo and to_date(to_char(a.cita_fecha_reg, 'dd/mm/yyyy'), 'dd/mm/yyyy') = to_date(to_char(b.cita_fecha_reg, 'dd/mm/yyyy'), 'dd/mm/yyyy') and a.secuencia = b.secuencia and a.compania = b.compania and a.trx_estado = 'P' and a.cod_articulo = b.cod_articulo and a.cod_articulo = c.cod_articulo and a.compania = c.compania and a.cita_codigo = d.codigo and to_date(to_char(a.cita_fecha_reg, 'dd/mm/yyyy'), 'dd/mm/yyyy') = to_date(to_char(d.fecha_registro, 'dd/mm/yyyy'), 'dd/mm/yyyy') and a.compania = " + (String) session.getAttribute("_companyId") + " and a.cod_articulo = e.cod_articulo  and e.codigo_almacen = "+ almacenSOP + appendFilter+" and a.compania = e.compania order by c.descripcion";
		
		change = "1";
		System.out.println("sql detail:\n"+sql);
		al = SQLMgr.getDataList(sql);
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp"%>
<script language="javascript">
function doAction(){
	<%
	if(type!=null && type.equals("1")){
	%>
	<%
	}
	%>
	calc();
}

function chkValue(i){
	var x1 = 0, x2 = 0, x3 = 0;
	var disponible = parseInt(eval('document.form.disponible'+i).value, 10);
	var adicion = parseInt(eval('document.form.adicion'+i).value, 10);
	var afecta_inv		= eval('document.form.afecta_inv'+i).value;
	if(disponible < 0){
		x1++;
	}
	if(disponible==0){
		x2++;
	} else if(adicion > disponible){
		<%if(cdoP.getColValue("valida_dsp").trim().equals("S")){%>eval('document.form.adicion'+i).value = 0;<%}%>
		x3++;
	}

	if((x1+x2+x3)>0){
	<%if(cdoP.getColValue("valida_dsp").trim().equals("S")){%>
	if(afecta_inv=='Y'){
		if(x1>0) CBMSG.warning('No hay existencia...,VERIFIQUE SU INVENTARIO!-DISPONIBLE EN NEGATIVO');
		else if(x2>0) CBMSG.warning('No hay existencia...,VERIFIQUE SU INVENTARIO!');
		else if(x3>0) CBMSG.warning('Cantidad NO disponible en Inventario...,VERIFIQUE SU INVENTARIO');
		eval('document.form.chk'+i).checked = false;
		return false;
		}else return true;<%}else{%>return true;<%}%>
	} else return true;
}

function calc(){
}

function chkAll(){
	var x1 = 0, x2 = 0, x3 = 0;
	var size = document.form.keySize.value;
	for(i=0;i<size;i++){
		if(document.form.chk.checked==true) eval('document.form.chk'+i).checked=true;
		else eval('document.form.chk'+i).checked=false;
	}
}

function anular(){
	document.form.baction.value = 'anular';
	doSubmit();
}

function aplicartrx(){
	var x = 0, x2 = 0, x3 = 0;
	var msg = '';
	var size = document.form.keySize.value;
	for(i=0;i<size;i++){
		if(eval('document.form.chk'+i).checked==true){
			if(!chkValue(i)){
				x3 = 1;
				break;
			}
			x2++;
			var disponible	= parseInt(eval('document.form.disponible'+i).value, 10);
			var entrega			=	parseInt(eval('document.form.entrega'+i).value, 10);
			var adicion			=	parseInt(eval('document.form.adicion'+i).value, 10);
			var devolucion	=	parseInt(eval('document.form.devolucion'+i).value, 10);
			var trx_tipo	=	eval('document.form.trx_tipo'+i).value;
	
			var cant_nuevo		= parseInt(eval('document.form.cant_nuevo'+i).value, 10);
			var cant_devolucion			=	parseInt(eval('document.form.cant_devolucion'+i).value, 10);
			var cant_adicion			=	parseInt(eval('document.form.cant_adicion'+i).value, 10);
			var p_cantidad = cant_adicion + cant_nuevo - cant_devolucion;
			
			var v_total = (entrega + adicion + p_cantidad) - devolucion;
			if(v_total<0){
				x++;
				if (trx_tipo == 'D') v_texto = 'DEVOLUCION';
				else v_texto = 'PEDIDO/ADICION';
				msg = 'La transacción de '+ v_texto + ', del artículo '+ eval('document.form.art_familia'+i).value + '-' + eval('document.form.art_clase'+i).value + '-' + eval('document.form.cod_articulo'+i).value;
				break;
			}
		}
	}
	if(x3==1) null;
	else if(x2==0) CBMSG.warning('Seleccione al menos un artículo!');
	else if(x>0) CBMSG.warning(msg);
	else{
		document.form.baction.value = 'aplicar';
		doSubmit();
	}
}

function doSubmit(){
	document.form.submit();
}

</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" bgcolor="#fafbfa" onLoad="javascript:doAction()">
<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
<table align="center" width="99%" cellpadding="0" cellspacing="0">
  <tr>
    <td>&nbsp;</td>
  </tr>
  <tr>
    <td class="TableBorder"><table align="center" width="100%" cellpadding="5" cellspacing="1">
        <tr class="TextFilter">
          <%
					fb = new FormBean("search00",request.getContextPath()+request.getServletPath(),"GET","");
					%>
          <%=fb.formStart()%> 
					<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%> 
					<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
          <%=fb.hidden("fp",fp)%>
					<%=fb.hidden("fg",fg)%>
					<%=fb.hidden("codCita",codCita)%> 
          <%=fb.hidden("fechaCita",fechaCita)%> 
          <%=fb.hidden("secuencia",secuencia)%>
          <%=fb.hidden("tipoSolicitud",request.getParameter("tipoSolicitud"))%>
          <td>
          	Paciente
          	<%=fb.textBox("paciente","",false,false,false,40,null,null,"")%>
            Flia.
            <%=fb.intBox("familia","",false,false,false,10,null,null,"")%>
            Clase
            <%=fb.intBox("clase","",false,false,false,10,null,null,"")%>
            <cellbytelabel>Art&iacute;culo</cellbytelabel>
            <%=fb.intBox("articulo","",false,false,false,10,null,null,"")%>
            <cellbytelabel>Descripci&oacute;n</cellbytelabel>
            <%=fb.textBox("desc_articulo","",false,false,false,40,null,null,"")%>
						<%=fb.submit("go","Ir")%> 
					</td>
          <%=fb.formEnd()%>
				</tr></table></td></tr>
<%
fb = new FormBean("form",request.getContextPath()+request.getServletPath(),FormBean.POST);
%>
<%=fb.formStart(true)%> 
<%=fb.hidden("mode",mode)%> 
<%=fb.hidden("size",""+al.size())%> 
<%=fb.hidden("baction","")%> 
<%=fb.hidden("fp",fp)%> 
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("codCita",codCita)%> 
<%=fb.hidden("fechaCita",fechaCita)%> 
<%=fb.hidden("secuencia",secuencia)%>
<%=fb.hidden("tipoSolicitud",request.getParameter("tipoSolicitud"))%>
<%
int colspan = 12;
%>
  <tr>
    <td class="TableBorder"><table align="center" width="100%" cellpadding="5" cellspacing="1">
        <tr class="TextHeader02">
          <td width="30%" align="center" rowspan="2"><cellbytelabel>Paciente</cellbytelabel></td>
          <td width="18%" align="center" colspan="3"><cellbytelabel>C&oacute;digo art&iacute;culo</cellbytelabel></td>
          <td width="30%" align="center" rowspan="2"><cellbytelabel>Nombre del Art&iacute;culo</cellbytelabel></td>
		   <td width="7%" align="center" rowspan="2"><cellbytelabel>DISPONIBLE</cellbytelabel></td>
          <td width="7%" align="center" rowspan="2"><cellbytelabel>ENTREGA</cellbytelabel></td>
          <td width="7%" rowspan="2"><cellbytelabel>ADICI&Oacute;N</cellbytelabel></td>
          <td width="7%" align="right" rowspan="2"><cellbytelabel>DEVOLUC</cellbytelabel>.</td>
          <td width="10%" align="right" rowspan="2"><%=fb.checkbox("chk", "", false, false, "Text10", "", "onClick=\"javascript:chkAll()\"")%></td>
          <td width="7%" align="right" rowspan="2"><cellbytelabel>Usuario</cellbytelabel></td>
          <td width="7%" align="right" rowspan="2"><cellbytelabel>Hora</cellbytelabel></td>
        </tr>
        <tr class="TextHeader02" align="center">
          <td><cellbytelabel>Fl&iacute;a</cellbytelabel></td>
          <td><cellbytelabel>Clase</cellbytelabel></td>
          <td><cellbytelabel>Art&iacute;culo</cellbytelabel></td>
        </tr>
        <%
for (int i=0; i<al.size(); i++){
	CommonDataObject ad = (CommonDataObject) al.get(i);

	String color = "";
	
	if (i%2 == 0) color = "TextRow02";
	else color = "TextRow01";
	boolean readonly = true;
%>
<%=fb.hidden("entrega"+i, ad.getColValue("entrega"))%>
<%=fb.hidden("devolucion"+i, ad.getColValue("devolucion"))%>
<%=fb.hidden("adicion"+i, ad.getColValue("adicion"))%>
<%=fb.hidden("disponible"+i, ad.getColValue("disponible"))%>
<%=fb.hidden("trx_tipo"+i, ad.getColValue("trx_tipo"))%>
<%=fb.hidden("cita_codigo"+i, ad.getColValue("cita_codigo"))%>
<%=fb.hidden("cita_fecha_reg"+i, ad.getColValue("cita_fecha_reg"))%>
<%=fb.hidden("secuencia"+i, ad.getColValue("secuencia"))%>
<%=fb.hidden("afecta_inv"+i, ad.getColValue("afecta_inv"))%>

        <tr class="<%=color%>" align="center">
          <td>&nbsp;<%=ad.getColValue("nombre_paciente")%></td>
          <td><%=fb.textBox("art_familia"+i, ad.getColValue("art_familia"), false, false, true, 8, "Text10", "", "")%></td>
          <td><%=fb.textBox("art_clase"+i, ad.getColValue("art_clase"), false, false, true, 8, "Text10", "", "")%></td>
          <td><%=fb.textBox("cod_articulo"+i, ad.getColValue("cod_articulo"), false, false, true, 8, "Text10", "", "")%></td>
          <td><%=fb.textBox("descripcion"+i, ad.getColValue("descripcion"), false, false, true, 65, "Text10", "", "")%></td>
		  <%if(Double.parseDouble(ad.getColValue("disponible")) <=0){%>
		  <td class="RedTextBold"><%=ad.getColValue("disponible")%></td>
		  <%}else{%> <td><%=ad.getColValue("disponible")%></td>
		  <%}%>
          <td><%=fb.intBox("cant_nuevo"+i, ad.getColValue("cant_nuevo"), false, false, true, 8, "Text10", null, "")%></td>
          <td><%=fb.intBox("cant_adicion"+i, ad.getColValue("cant_adicion"), false, false, true, 8, "Text10", null, "")%></td>
          <td><%=fb.intBox("cant_devolucion"+i, ad.getColValue("cant_devolucion"), false, false, true, 8, "Text10", null, "")%></td>
          <!--
          <td><%=fb.checkbox("chk"+i, "", false, false, "Text10", "", "onClick=\"javascript:chkValue("+i+")\"")%></td>
          -->
          <td><%=fb.checkbox("chk"+i, "", false, false, "Text10", "", "")%></td>
          <td><%=fb.intBox("usuario_solicita"+i, ad.getColValue("usuario_solicita"), false, false, false, 8, "Text10", null, "")%></td>
          <td><%=fb.intBox("txr_hora"+i, ad.getColValue("txr_hora"), false, false, true, 8, "Text10", null, "")%></td>
        </tr>
        <%
}
%>
        <%=fb.hidden("keySize",""+al.size())%>
        <tr>
          <td colspan="12" align="right"><%=fb.button("anularx","Anular TRX",true,viewMode,null,null,"onClick=\"javascript:anular()\"")%><%=fb.button("aplicar","Aplicar TRX",true,viewMode,null,null,"onClick=\"javascript:aplicartrx()\"")%></td>
        </tr>
        <tr class="TextRow02">
          <td colspan="12" align="right"><%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%> </td>
        </tr>
      </table>
</table>
</td>
</tr>
</table>
</td>
<%=fb.formEnd(true)%>
<!-- ================================   F O R M   E N D   H E R E   ================================ -->
</body>
</html>
<%
}//GET 
else
{
	String dl = "";
	//Ajuste CdcSol = new Ajuste();
	int keySize = Integer.parseInt(request.getParameter("keySize"));
	String clearHT = request.getParameter("clearHT");
	if(clearHT==null) clearHT = "N";
	if(clearHT.equals("S")) keySize = 0;

	String anio = CmnMgr.getCurrentDate("yyyy");
	
	int size = Integer.parseInt(request.getParameter("size"));

	lineNo = 0;
	ArrayList detail = new ArrayList();
	String _key = "", okey = "";
	
	for (int i=0; i<keySize; i++){
		CdcSolicitudDet det = new CdcSolicitudDet();
		det.setCitaCodigo(request.getParameter("cita_codigo"+i));
		det.setCitaFechaReg(request.getParameter("cita_fecha_reg"+i));
		det.setSecuencia(request.getParameter("secuencia"+i));
		det.setCompania((String) session.getAttribute("_companyId"));
		det.setAfectaInv(request.getParameter("afecta_inv"+i));
		
		if(request.getParameter("art_familia"+i)!=null && !request.getParameter("art_familia"+i).equals("null") && !request.getParameter("art_familia"+i).equals("")) det.setArtFamilia(request.getParameter("art_familia"+i));

		if(request.getParameter("art_clase"+i)!=null && !request.getParameter("art_clase"+i).equals("null") && !request.getParameter("art_clase"+i).equals("")) det.setArtClase(request.getParameter("art_clase"+i));

		if(request.getParameter("cod_articulo"+i)!=null && !request.getParameter("cod_articulo"+i).equals("null") && !request.getParameter("cod_articulo"+i).equals("")) det.setCodArticulo(request.getParameter("cod_articulo"+i));

		if(request.getParameter("cant_adicion"+i)!=null && !request.getParameter("cant_adicion"+i).equals("null") && !request.getParameter("cant_adicion"+i).equals("")) det.setAdicion(request.getParameter("cant_adicion"+i));
		else det.setAdicion("0");

		if(request.getParameter("cant_devolucion"+i)!=null && !request.getParameter("cant_devolucion"+i).equals("null") && !request.getParameter("cant_devolucion"+i).equals("")) det.setDevolucion(request.getParameter("cant_devolucion"+i));
		else det.setDevolucion("0");

		if(request.getParameter("cant_nuevo"+i)!=null && !request.getParameter("cant_nuevo"+i).equals("null") && !request.getParameter("cant_nuevo"+i).equals("")) det.setCantNuevo(request.getParameter("cant_nuevo"+i));
		else det.setCantNuevo("0");

		if(request.getParameter("trx_tipo"+i)!=null && !request.getParameter("trx_tipo"+i).equals("null") && !request.getParameter("trx_tipo"+i).equals("")) det.setTrxTipo(request.getParameter("trx_tipo"+i));

		if(request.getParameter("chk"+i)!=null){
			detail.add(det);
		}
		
	}

	System.out.println("baction="+request.getParameter("baction"));
	
	if(request.getParameter("baction")!=null && request.getParameter("baction").equals("Agregar Cargos")){
		response.sendRedirect("../facturacion/reg_cargo_dev_det_so_2.jsp?mode="+mode+"&change=1&change2=1&type=1&fg="+fg+"&tipoSolicitud="+tipoSolicitud+"&secuencia="+secuencia+"&codCita="+codCita+"&fechaCita="+fechaCita);
		return;
	}
	
	System.out.println("request.getParameter(addCargos)="+request.getParameter("addCargos"));

	if (request.getParameter("baction").equalsIgnoreCase("aplicar")){
		CdcSolMgr.AplicarTrx(detail);
	} else if (request.getParameter("baction").equalsIgnoreCase("anular")){
		CdcSolMgr.AnularTrx(detail);
	}

%>
<html>
<head>
<script language="javascript" src="../js/capslock.js"></script>
<script language="javascript">
function closeWindow(){
<%
if (CdcSolMgr.getErrCode().equals("1")){
%>
	alert('<%=CdcSolMgr.getErrMsg()%>');
<%
	if(fp!=null && fp.equals("cargo_dev_so")){
%>
	window.opener.location = '../facturacion/reg_cargo_dev_det_so_2.jsp?fp=<%=fp%>&fg=<%=fg%>&mode=<%=mode%>&fechaCita=<%=fechaCita%>&codCita=<%=codCita%>&tipoSolicitud=<%=request.getParameter("tipoSolicitud")%>';
	<%
	} else if(fp!=null && fp.equals("quirofano") && fg!=null && fg.equals("inv")){
	%>
	window.opener.location = '../cita/quirofano_list.jsp?fechaCita=<%=fechaCita%>&fp=<%=fp%>&fg=<%=fg%>';
	<%
	}else if(fp!=null && fp.equals("quirofano") && fg!=null && fg.equals("SO")){
	%>
	window.opener.location = '../cita/cita_x_hab_list.jsp?fechaCita=<%=fechaCita%>&fp=<%=fp%>&fg=<%=fg%>';
	<%
	}
	%>
	window.close();
<%
} else throw new Exception(CdcSolMgr.getErrMsg());
%>
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>
