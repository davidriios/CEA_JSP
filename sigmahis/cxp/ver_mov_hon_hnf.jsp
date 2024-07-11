<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="java.util.Vector" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" %>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />

<%
/**
======================================================================================================================================================
FORMA								MENU																																				NOMBRE EN FORMA
======================================================================================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
//if (!(SecMgr.checkAccess(session.getId(),"0"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

SQL2BeanBuilder sbb = new SQL2BeanBuilder();
ArrayList al = new ArrayList();
CommonDataObject cdo = new CommonDataObject();
CommonDataObject cdoT = new CommonDataObject();
StringBuffer sbSql = new StringBuffer();
String mode = request.getParameter("mode");
String fg = request.getParameter("fg");
String fp = request.getParameter("fp");
String fechaini = request.getParameter("fechaini");
String fechafin = request.getParameter("fechafin");
String beneficiario = request.getParameter("beneficiario");
String tipo = request.getParameter("tipo");
String acumHonNoFacturaro = request.getParameter("acumHonNoFacturaro");

if(fg==null) fg = "";
if(fp==null) fp = "";
if(acumHonNoFacturaro==null) acumHonNoFacturaro = "";

boolean viewMode = false;
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy");
String mTime = CmnMgr.getCurrentDate("hh12:mi:ss am");
String fecha = request.getParameter("fecha");
if(fecha==null) fecha = cDateTime;
int lineNo = 0;
if (mode == null) mode = "add";
if (request.getMethod().equalsIgnoreCase("GET"))
{
	sbSql.append("select decode('");
	sbSql.append(tipo);
	sbSql.append("', 'E', (select nombre from tbl_adm_empresa e where to_char(e.codigo) = '");
	sbSql.append(beneficiario);
	sbSql.append("'), (select decode(m.sexo, 'F', 'Dra. ', 'Dr. ') || m.primer_nombre || decode(m.segundo_nombre, null, '', ' ' || m.segundo_nombre) || ' ' || m.primer_apellido || decode(m.segundo_apellido, null, '', ' ' || m.segundo_apellido) || decode(m.sexo, 'F', decode(m.apellido_de_casada, null, '', ' ' || m.apellido_de_casada)) from tbl_adm_medico m where m.codigo = '");
	sbSql.append(beneficiario);
	sbSql.append("')) nombre_beneficiario, '01/'||to_char(sysdate, 'mm/yyyy') fecha_ini, to_char(last_day(sysdate), 'dd/mm/yyyy') fecha_fin from dual");

	cdo = SQLMgr.getData(sbSql.toString());
	if(fechaini==null) fechaini = cdo.getColValue("fecha_ini");
	if(fechafin==null) fechafin = cdo.getColValue("fecha_fin");
	
	CommonDataObject cdoF = SQLMgr.getData("select get_sec_comp_param("+(String)session.getAttribute("_companyId")+",'CXP_EST_CTA_HON_FORMAT') as format from dual");
	if (cdoF==null) cdoF = new CommonDataObject(); 
	String format = cdoF.getColValue("format")==null || cdoF.getColValue("format").equals("")?"0":cdoF.getColValue("format");
	
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<script language="javascript">
document.title = 'CXP - '+document.title;

function setValues(){
	var fechaini = document.form1.fechaini.value;
	var fechafin = document.form1.fechafin.value;
	var acumHonNoFacturaro = document.form1.acumHonNoFacturaro.value;
	var trx = document.form1.trx.value;
	window.frames['itemFrame'].location = '../cxp/ver_mov_hon_det_hnf.jsp?beneficiario=<%=beneficiario%>&tipo=<%=tipo%>&fechaini='+fechaini+'&fechafin='+fechafin+'&format=<%=format%>'+'&acumHonNoFacturaro='+acumHonNoFacturaro+'&trx='+trx;
}

function printMovimiento()
{	
	var fechaini = document.form1.fechaini.value;
	var fechafin = document.form1.fechafin.value;
	var acumHonNoFacturaro = document.form1.acumHonNoFacturaro.value;
	var trx = document.form1.trx.value;
	abrir_ventana2('../cellbyteWV/report_container.jsp?reportName=cxp/rpt_mov_hon_hnf.rptdesign&desdeParam='+fechaini+'&hastaParam='+fechafin+'&medicoParam=<%=beneficiario%>&tipoParam=<%=tipo%>&benefNameParam=<%=IBIZEscapeChars.forURL(cdo.getColValue("nombre_beneficiario"))%>&format=<%=format%>'+'&ahnfParam='+acumHonNoFacturaro+'&trx='+trx);
}

</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" bgcolor="#fafbfa" onLoad="">
<jsp:include page="../common/title.jsp" flush="true">
<jsp:param name="title" value="MAYOR GENERAL"></jsp:param>
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
										<%=fb.hidden("format",format)%>
										<%=fb.hidden("acumHonNoFacturaro",acumHonNoFacturaro)%>
										<tr>
											<td align="right">
											<authtype type='2'>
											<a href="javascript:printMovimiento()" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')"><font class="RedTextBold"> <cellbytelabel>Reporte</cellbytelabel></font></a>
											</authtype></td>
										</tr>
                    <tr>
                      <td><table width="100%" cellpadding="1" cellspacing="0">
                      		<tr>
                          <td colspan="2" align="right">&nbsp;</td>
                          </tr>
                          <tr class="TextPanel">
                            <td colspan="2"><cellbytelabel>Fecha</cellbytelabel>
                            <jsp:include page="../common/calendar.jsp" flush="true">
                            <jsp:param name="noOfDateTBox" value="2" />
                            <jsp:param name="clearOption" value="true" />
                            <jsp:param name="nameOfTBox1" value="fechaini" />
                            <jsp:param name="valueOfTBox1" value="<%=fechaini%>" />
                            <jsp:param name="nameOfTBox2" value="fechafin" />
                            <jsp:param name="valueOfTBox2" value="<%=fechafin%>" />
                            <jsp:param name="fieldClass" value="text10" />
                            <jsp:param name="buttonClass" value="text10" />
                            </jsp:include>
														Transacciones
														<%=fb.select("trx","T=TODAS,P=PENDIENTES,C=SALDADAS","")%>
                      			<%=fb.button("ir","Ir",true,false,"","","onClick=\"javascript:setValues();\"")%>
                            </td>
                          </tr>
                          <tr class="TextHeader02" height="21">
                            <td><cellbytelabel>C&oacute;digo</cellbytelabel>:&nbsp;&nbsp;<%=beneficiario%></td>
                            <td><cellbytelabel>Nombre</cellbytelabel>:&nbsp;&nbsp;<%=cdo.getColValue("nombre_beneficiario")%></td>
                          </tr>
                        </table></td>
                    </tr>
                    <tr>
                      <td><iframe name="itemFrame" id="itemFrame" frameborder="0" align="center" width="100%" height="300" scrolling="yes" src="../cxp/ver_mov_hon_det_hnf.jsp?fp=<%=fp%>&fg=<%=fg%>&mode=<%=mode%>&beneficiario=<%=beneficiario%>&tipo=<%=tipo%>&fechaini=<%=fechaini%>&fechafin=<%=fechafin%>&format=<%=format%>&acumHonNoFacturaro=<%=acumHonNoFacturaro%>"></iframe></td>
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
<%@ include file="../common/footer.jsp"%>
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
	if (request.getParameter("baction").equalsIgnoreCase("Aplicar Accion de Ingreso") || request.getParameter("baction").equalsIgnoreCase("Anular Accion de Ingreso")){
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
	window.location = '<%=request.getContextPath()+request.getServletPath()%>';
<%
} else throw new Exception(errMsg);
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
