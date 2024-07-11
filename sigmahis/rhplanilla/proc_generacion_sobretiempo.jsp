<%//@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="java.util.Vector" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" %>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="AEmpMgr" scope="page" class="issi.rhplanilla.AccionesEmpleadoMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="emp" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="empKey" scope="session" class="java.util.Hashtable" />

<%
/**
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");

UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);
AEmpMgr.setConnection(ConMgr);

SQL2BeanBuilder sbb = new SQL2BeanBuilder();
ArrayList al = new ArrayList();
CommonDataObject cdo = new CommonDataObject();
emp.clear();
empKey.clear();
String key = "";
String sql = "";
String mode = request.getParameter("mode");
String fg = request.getParameter("fg");
String fp = request.getParameter("fp");
String grupo = request.getParameter("grupo");
String area = request.getParameter("area");
String anio = request.getParameter("anio");
String mes = request.getParameter("mes");

String periodo = request.getParameter("anio");
String quincena = request.getParameter("mes");
String cierre = request.getParameter("cierre");
String desde = request.getParameter("desde");
String hasta = request.getParameter("hasta");

if(fg==null) fg = "";
if(grupo==null) grupo = "";
if(area==null) area = "";
if(fp==null) fp = "";
if(anio==null) anio = "";
if(mes==null) mes = "";

boolean viewMode = false;
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy");
String mTime = CmnMgr.getCurrentDate("hh12:mi:ss am");
String fecha = request.getParameter("fecha");
if(fecha==null) fecha = cDateTime;
int lineNo = 0;
if (mode == null) mode = "add";
if (request.getMethod().equalsIgnoreCase("GET"))
{
	if (mode.equalsIgnoreCase("add"))
	{
/*     
	sql="select	to_char(trans_desde,'dd/mm/yyyy') desde, to_char(trans_hasta,'dd/mm/yyyy') hasta, to_char(fecha_cierre,'dd/mm/yyyy') cierre, periodo, decode(substr(fecha_inicial,0,2), '01', 'PRIMERA', '16', 'SEGUNDA') quincena, to_char(fecha_inicial,'yyyy') anio, to_char(sysdate,'FMMONTH','NLS_DATE_LANGUAGE=SPANISH') mes from	tbl_pla_calendario where tipopla = 1 and trunc(fecha_cierre) < to_date('"+fecha+"','dd/mm/yyyy') and trunc(fecha_inicial)	<= to_date('"+fecha+"','dd/mm/yyyy') and trunc(fecha_final) >= to_date('"+fecha+"','dd/mm/yyyy')";
	*/
	
	//  se pone fijo para prueba  periodo 15
	sql="select	to_char(trans_desde,'dd/mm/yyyy') desde, to_char(trans_hasta,'dd/mm/yyyy') hasta, to_char(fecha_cierre,'dd/mm/yyyy') cierre, periodo, decode(substr(fecha_inicial,0,2), '01', 'PRIMERA', '16', 'SEGUNDA') quincena, to_char(fecha_inicial,'yyyy') anio, to_char(sysdate,'FMMONTH','NLS_DATE_LANGUAGE=SPANISH') mes from	tbl_pla_calendario where tipopla = 1 and periodo=15";
	
		cdo = SQLMgr.getData(sql);
		if(cdo==null) cdo = new CommonDataObject();
		periodo = cdo.getColValue("periodo");
		anio = cdo.getColValue("anio");
		mes = cdo.getColValue("mes");
		quincena = cdo.getColValue("quincena");
		cierre = cdo.getColValue("cierre");
		desde = cdo.getColValue("desde");
		hasta = cdo.getColValue("hasta");
			//	System.out.println("in...................."||sql);

	}

%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<%@ include file="../common/tab.jsp" %>
<script language="javascript">
document.title = 'PLANILLA - '+document.title;

function doSubmit(value){
	window.frames['itemFrame'].document.form3.baction.value = value;
	window.frames['itemFrame'].doSubmit(value);
}

function doAction(){
//	setTextValues();
	setHeight('itemFrame',document.body.scrollHeight);
}

function imprimir(){
	abrir_ventana('../inventario/print_list_articulos_axa.jsp');
}

function setValues(){
	var mes = document.form1.mes.value;
	var anio = document.form1.anio.value;
	var periodo = document.form1.periodo.value;
	var quincena = document.form1.quincena.value;
	var grupo = document.form1.grupo.value;
	if(anio!='' && mes !=''){
	window.location = '../rhplanilla/proc_generacion_sobretiempo_det.jsp?mode=add&periodo='+periodo+'&mes='+mes+'&anio='+anio+'&quincena='+quincena+'&cierre='+cierre+'&grupo='+grupo+'&fp=<%=fp%>';
	}
}

function setTextValues(){
	//window.frames['itemFrame'].setTextValues();
	//var uf_codigo = document.form1.uf_codigo.value;
	var mes = document.form1.mes.value;
	var anio = document.form1.anio.value;
	var periodo = document.form1.periodo.value;
	var quincena = document.form1.quincena.value;
	var cierre = document.form1.cierre.value;
	var grupo = document.form1.grupo.value;
	var desde = document.form1.desde.value;
	var hasta = document.form1.hasta.value;

	if(anio!='' && mes !=''){
	window.frames['itemFrame'].location = '../rhplanilla/proc_genera_sobretiempo_det.jsp?mode=view&anio='+anio+'&mes='+mes+'&periodo='+periodo+'&quincena='+quincena+'&cierre='+cierre+'&desde='+desde+'&hasta='+hasta+'&grupo='+grupo+'&fp=<%=fp%>';
	}
}


function reversar(){
	if(document.form1.grupo.value!='' && window.frames['itemFrame'].document.getElementById('keySize')!=0) window.frames['itemFrame'].reversar('all');
}

</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" bgcolor="#fafbfa" onLoad="javascript:doAction()">
<jsp:include page="../common/title.jsp" flush="true">
<jsp:param name="title" value="GENERACION DE SOBRETIEMPO"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
  <tr>
    <td class="TableBorder"><table align="center" width="100%" cellpadding="5" cellspacing="0">
        <tr>
          <td class="TableBorder"><table align="center" width="100%" cellpadding="5" cellspacing="0">
              <tr>
                <td><table align="center" width="100%" cellpadding="0" cellspacing="1">
                    <!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
                    <%fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
                    <%=fb.formStart(true)%>
			<%=fb.hidden("mode",mode)%>
			<%=fb.hidden("errCode","")%>
			<%=fb.hidden("errMsg","")%>
			<%=fb.hidden("baction","")%>
			<%=fb.hidden("fg",fg)%>
			<%=fb.hidden("fp",fp)%>
			<%=fb.hidden("clearHT","")%>
                    	<%=fb.hidden("fecha_inicio","")%>
                    	<%=fb.hidden("fecha_final","")%>
                    	<%=fb.hidden("finicio","")%>
                    	<%=fb.hidden("ffinal","")%>
                    	<%=fb.hidden("num_periodo","")%>

                    <tr>
                      <td><table width="100%" cellpadding="1" cellspacing="0">
                          <tr class="TextPanel">
                            <td colspan="2">&nbsp;Parámetros para Generación de Sobretiempo</td>
                          </tr>
			  <tr class="TextRow01" align="right">
                            <td colspan="2">&nbsp;Fecha Inicio &nbsp;
				<%=fb.textBox("desde",cdo.getColValue("desde"),true,false,true,10,"text10","","")%>
				&nbsp;&nbsp;
			  </td>
                          </tr>
			    <tr class="TextRow01">
                            <td align="left">&nbsp;
                            No. Periodo :
				<%=fb.textBox("periodo",cdo.getColValue("periodo"),true,false,false,4,"text10","","")%>
				&nbsp;&nbsp; Año :
				<%=fb.textBox("anio",anio,true,false,true,4,"text10","","")%>
                            &nbsp; &nbsp;Mes :
				<%=fb.textBox("mes",mes,true,false,true,14,"text10","","")%>
			    &nbsp;&nbsp; Quincena :
				<%=fb.textBox("quincena",quincena,true,false,true,14,"text10","","")%>
                            </td>
                            <td align="right">&nbsp;Fecha Final &nbsp;
				<%=fb.textBox("hasta",cdo.getColValue("hasta"),true,false,true,10,"text10","","")%>
				&nbsp;&nbsp;
				</td>
                          </tr>
                          <tr class="TextRow01">
                            <td>&nbsp;Unidad a Generar :
                           	<%=fb.select(ConMgr.getConnection(),"select codigo as grupo,  codigo||'-'||descripcion descripcion, codigo from tbl_pla_ct_grupo where compania="+(String) session.getAttribute("_companyId")+" order by 1","grupo","",false,false,0,"Text10",null,null,null,"T")%>
                            &nbsp;&nbsp;<%=fb.button("ir","  Ir  ",false,false,"text10","","onClick=\"javascript:setTextValues();\"")%></td>
                            <td  align="right">&nbsp;Cierre &nbsp;<%=fb.textBox("cierre",cierre,true,false,true,10,"text10","","")%>&nbsp;&nbsp;&nbsp;</td>
                          </tr>

                         	

                        </table></td>
                    </tr>
                    <tr>
                      <td><iframe name="itemFrame" id="itemFrame" frameborder="0" align="center" width="100%" height="300" scrolling="yes" src="../rhplanilla/proc_genera_sobretiempo_det.jsp?mode=add&desde=<%=desde%>&hasta=<%=hasta%>&anio=<%=request.getParameter("anio")%>&periodo=<%=request.getParameter("periodo")%>&grupo=<%=request.getParameter("grupo")%>&fp=<%=fp%>&fg=<%=fg%>"></iframe></td>
                    </tr>

                    <%=fb.formEnd(true)%>
                    <!-- ================================   F O R M   E N D   H E R E   ================================ -->
                  </table></td>
              </tr>
            </table></td>
        </tr>
        <!-- ================================   F O R M   E N D   H E R E   ================================ -->
      </table></td>
  </tr>
</table>
</td>
</tr>
</table>
<%//@ include file="../common/footer.jsp"%>
</body>
</html>
<%
}//GET
else
{
	String saveOption = request.getParameter("saveOption");//N=Create New,O=Keep Open,C=Close
	String errCode = "";
	String errMsg = "";
	fp = request.getParameter("fp");
	if (request.getParameter("baction").equalsIgnoreCase("EJECUTAR"))
	{
		errCode = request.getParameter("errCode");
		errMsg = request.getParameter("errMsg");
	}
		if (request.getParameter("baction").equalsIgnoreCase("ELIMINAR"))
	{
		errCode = request.getParameter("errCode");
		errMsg = request.getParameter("errMsg");
	}
	if (request.getParameter("baction").equalsIgnoreCase("Guardar"))
	{
		errCode = request.getParameter("errCode");
		errMsg = request.getParameter("errMsg");
	}

%>
<html>
<head>
<script language="javascript" src="../js/capslock.js"></script>
<script language="javascript">
function closeWindow()
{
<%
if (errCode.equals("1")){
%>
	alert('<%=errMsg%>');
<%
	if (saveOption.equalsIgnoreCase("O")){
%>
	setTimeout('addMode()',500);
<%
	}	else if (saveOption.equalsIgnoreCase("C")){
%>
	window.close();
<%
	}
} else throw new Exception(errMsg);
%>
}

function addMode(){
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?mode=add&grupo=<%=grupo%>&area=<%=area%>&anio=<%=request.getParameter("anio")%>&mes=<%=request.getParameter("mes")%>';
}

</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>
