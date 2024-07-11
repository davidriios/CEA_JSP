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
String sql = "";
String mode = request.getParameter("mode");
String fg = request.getParameter("fg");
String fp = request.getParameter("fp");
String fechaini = request.getParameter("fechaini");
String fechafin = request.getParameter("fechafin");
String cod_proveedor = request.getParameter("cod_proveedor");
String tipoFac = request.getParameter("tipoFac");
String doc_morosidad = request.getParameter("doc_morosidad");

if(fg==null) fg = "";
if(fp==null) fp = "";
if(tipoFac==null) tipoFac = "";

boolean viewMode = false;
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy");
String mTime = CmnMgr.getCurrentDate("hh12:mi:ss am");
String fecha = request.getParameter("fecha");
if(fecha==null) fecha = cDateTime;
int lineNo = 0;
if (mode == null) mode = "add";
if (request.getMethod().equalsIgnoreCase("GET"))
{
	sql = "select nombre_proveedor nombre, '01/'||to_char(sysdate, 'mm/yyyy') fecha_ini, to_char(last_day(sysdate), 'dd/mm/yyyy') fecha_fin from tbl_com_proveedor where compania = "+(String) session.getAttribute("_companyId") + " and cod_provedor = " + cod_proveedor;
	cdo = SQLMgr.getData(sql);
	if(fechaini==null) fechaini = cdo.getColValue("fecha_ini");
	if(fechafin==null) fechafin = cdo.getColValue("fecha_fin");
	
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
	var noDoc = document.form1.noDoc.value;
	var tipoFac = document.form1.tipoFac.value;	
	window.frames['itemFrame'].location = '../cxp/ver_mov_proveedor_det.jsp?cod_proveedor=<%=cod_proveedor%>&fechaini='+fechaini+'&fechafin='+fechafin+'&tipoFac='+tipoFac+'&noDoc='+noDoc+'&doc_morosidad=<%=doc_morosidad%>&fg=<%=fg%>'; 
}

function printMovimiento()
{	
	var cod_proveedor = document.form1.cod_proveedor.value;
	var fechaini = document.form1.fechaini.value;
	var fechafin = document.form1.fechafin.value; 
	var noDoc = document.form1.noDoc.value;
	var tipoFac = document.form1.tipoFac.value;
	abrir_ventana2('../cellbyteWV/report_container.jsp?reportName=cxp/saldo_proveedor.rptdesign&fechaDesdeParam='+fechaini+'&fechaHastaParam='+fechafin+'&provParam='+cod_proveedor+'&provName=<%=IBIZEscapeChars.forURL(cdo.getColValue("nombre"))%>&tipoFacParam='+tipoFac+'&pNoDoc='+noDoc+'&doc_morosidad=<%=doc_morosidad%>&fg=<%=fg%>'); 
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
										<%=fb.hidden("cod_proveedor",cod_proveedor)%>
										<%=fb.hidden("tipoFac",tipoFac)%>
                    <tr>
                      <td align="right"><authtype type='2'><a href="javascript:printMovimiento()" class="btn_link">[ <cellbytelabel>Imprimir</cellbytelabel> ]</a></authtype>
											</td>
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
							Factura/Doc:<%=fb.textBox("noDoc","",false,false,false,25)%>
                      			<%=fb.button("ir","Ir",true,false,"","","onClick=\"javascript:setValues();\"")%>
                            </td>
                          </tr>
                          <tr class="TextHeader02" height="21">
                            <td><cellbytelabel>C&oacute;digo</cellbytelabel>:&nbsp;&nbsp;<%=cod_proveedor%></td>
                            <td><cellbytelabel>Nombre</cellbytelabel>:&nbsp;&nbsp;<%=cdo.getColValue("nombre")%></td>
                          </tr>
                        </table></td>
                    </tr>
                    <tr>
                      <td><iframe name="itemFrame" id="itemFrame" frameborder="0" align="center" width="100%" height="300" scrolling="yes" src="../cxp/ver_mov_proveedor_det.jsp?fp=<%=fp%>&fg=<%=fg%>&mode=<%=mode%>&cod_proveedor=<%=cod_proveedor%>&fechaini=<%=fechaini%>&fechafin=<%=fechafin%>&tipoFac=<%=tipoFac%>&doc_morosidad=<%=doc_morosidad%>"></iframe></td>
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
%>
