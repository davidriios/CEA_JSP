<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admision.CdcSolicitudDet"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" %>
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
//if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
//if (!(SecMgr.checkAccess(session.getId(),"0"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
CdcSolMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

SQL2BeanBuilder sbb = new SQL2BeanBuilder();
ArrayList al = new ArrayList();
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

String appendFilter = "";

if (request.getMethod().equalsIgnoreCase("GET"))
{

	sql = "select a.cod_articulo, a.art_familia, a.art_clase, a.cantidad, b.descripcion, b.cod_medida unidad, a.entrega, nvl(c.adicion, 0) adicion, nvl(c.devolucion, 0) devolucion, (a.entrega + nvl(c.adicion, 0) - nvl(c.devolucion, 0)) utilizado from tbl_cdc_solicitud_det a, tbl_inv_articulo b, (select art_familia, art_clase, cod_Articulo, sum(decode(trx_tipo, 'A', cant_adicion, 0)) adicion, sum(decode(trx_tipo, 'D', cant_devolucion, 0)) devolucion from tbl_cdc_solicitud_trx where cita_codigo = " + codCita + " and to_date(to_char(cita_fecha_reg, 'dd/mm/yyyy'), 'dd/mm/yyyy') = to_date('" + fechaCita + "', 'dd/mm/yyyy') and secuencia = " + secuencia + " and compania = "+(String) session.getAttribute("_companyId")+" and trx_estado != 'A' group by art_familia, art_clase, cod_Articulo) c where a.compania = b.compania and a.cod_articulo = b.cod_articulo and to_date(to_char(a.cita_fecha_reg, 'dd/mm/yyyy'), 'dd/mm/yyyy') = to_date('" + fechaCita + "', 'dd/mm/yyyy') and a.cita_codigo = " + codCita + " and a.compania = "+(String) session.getAttribute("_companyId")+" and a.secuencia = " + secuencia + " and a.cod_articulo = c.cod_articulo(+) and (a.entrega + nvl(c.adicion, 0) - nvl(c.devolucion, 0)) > 0";
		
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
function chkValue(i){
	if(eval('document.form.chk'+i).checked==true){ 
		if(eval('document.form.cant_devolucion'+i).value=='') eval('document.form.cant_devolucion'+i).value = eval('document.form.entrega'+i).value;
		else {
			if(parseInt(eval('document.form.cant_devolucion'+i).value, 10) > parseInt(eval('document.form.entrega'+i).value, 10)){
				CBMSG.warning('La cantidad a devolver no puede ser mayor que la entregada!');
				eval('document.form.cant_devolucion'+i).value = eval('document.form.entrega'+i).value;
			} 
		}
	} else eval('document.form.cant_devolucion'+i).value = '';
}

function chkAll(){
	var size = document.form.keySize.value;
	for(i=0;i<size;i++){
		if(document.form.chk.checked==true) eval('document.form.chk'+i).checked=true;
		else eval('document.form.chk'+i).checked=false;
		chkValue(i);
	}
}


function doSubmit(){
	document.form.baction.value = 'devolver';
	document.form.submit();
}

</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" bgcolor="#fafbfa">
<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
<table align="center" width="99%" cellpadding="0" cellspacing="0">
  <tr>
    <td>&nbsp;</td>
  </tr>
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
          <td width="25%" align="center" colspan="3"><cellbytelabel>C&oacute;digo art&iacute;culo</cellbytelabel></td>
          <td width="40%" align="center" rowspan="2"><cellbytelabel>Nombre del Art&iacute;culo</cellbytelabel></td>
          <td width="10%" align="center" rowspan="2"><cellbytelabel>Unidad Medida</cellbytelabel></td>
          <td width="10%" align="center" rowspan="2"><cellbytelabel>Cant. Entrega</cellbytelabel></td>
          <td width="10%" align="center" rowspan="2"><cellbytelabel>Cant. Devolver</cellbytelabel></td>
          <td width="5%" align="center" rowspan="2"><%=fb.checkbox("chk", "", false, false, "Text10", "", "onClick=\"javascript:chkAll()\"")%></td>
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
        <tr class="<%=color%>" align="center">
          <td><%=fb.textBox("art_familia"+i, ad.getColValue("art_familia"), false, false, true, 8, "Text10", "", "")%></td>
          <td><%=fb.textBox("art_clase"+i, ad.getColValue("art_clase"), false, false, true, 8, "Text10", "", "")%></td>
          <td><%=fb.textBox("cod_articulo"+i, ad.getColValue("cod_articulo"), false, false, true, 8, "Text10", "", "")%></td>
          <td><%=fb.textBox("descripcion"+i, ad.getColValue("descripcion"), false, false, true, 85, "Text10", "", "")%></td>
          <td><%=fb.intBox("unidad"+i, ad.getColValue("unidad"), false, false, true, 8, "Text10", null, "")%></td>
          <td><%=fb.intBox("entrega"+i, ad.getColValue("entrega"), false, false, true, 8, "Text10", null, "")%></td>
          <td><%=fb.intBox("cant_devolucion"+i, ad.getColValue("cant_devolucion"), false, false, false, 8, "Text10", null, "")%></td>
          <td><%=fb.checkbox("chk"+i, ""+i, false, false, "Text10", "", "onClick=\"javascript:chkValue("+i+");\"")%></td>
        </tr>
        <%
}
%>
        <%=fb.hidden("keySize",""+al.size())%>
        <tr>
          <td colspan="11" align="right">
					<%=fb.button("devolver","Devolver",true,viewMode,null,null,"onClick=\"javascript:doSubmit()\"")%>&nbsp;
					<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%> 
          </td>
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

	int keySize = Integer.parseInt(request.getParameter("keySize"));
	lineNo = 0;
	ArrayList detail = new ArrayList();
	
	for (int i=0; i<keySize; i++){
		CdcSolicitudDet det = new CdcSolicitudDet();
		det.setCitaCodigo(request.getParameter("codCita"));
		det.setCitaFechaReg(request.getParameter("fechaCita"));
		det.setSecuencia(request.getParameter("secuencia"));
		det.setCompania((String) session.getAttribute("_companyId"));
		det.setUsuario((String) session.getAttribute("_userName"));	

		if(request.getParameter("art_familia"+i)!=null && !request.getParameter("art_familia"+i).equals("null") && !request.getParameter("art_familia"+i).equals("")) det.setArtFamilia(request.getParameter("art_familia"+i));

		if(request.getParameter("art_clase"+i)!=null && !request.getParameter("art_clase"+i).equals("null") && !request.getParameter("art_clase"+i).equals("")) det.setArtClase(request.getParameter("art_clase"+i));

		if(request.getParameter("cod_articulo"+i)!=null && !request.getParameter("cod_articulo"+i).equals("null") && !request.getParameter("cod_articulo"+i).equals("")) det.setCodArticulo(request.getParameter("cod_articulo"+i));

		if(request.getParameter("cant_adicion"+i)!=null && !request.getParameter("cant_adicion"+i).equals("null") && !request.getParameter("cant_adicion"+i).equals("")) det.setAdicion(request.getParameter("cant_adicion"+i));
		else det.setAdicion("0");

		if(request.getParameter("cant_devolucion"+i)!=null && !request.getParameter("cant_devolucion"+i).equals("null") && !request.getParameter("cant_devolucion"+i).equals("")) det.setDevolucion(request.getParameter("cant_devolucion"+i));
		else det.setDevolucion("0");

		if(request.getParameter("chk"+i)!=null){
			detail.add(det);
		}
		
	}

	if (request.getParameter("baction").equalsIgnoreCase("devolver")){
		CdcSolMgr.devolverTrx(detail);
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
