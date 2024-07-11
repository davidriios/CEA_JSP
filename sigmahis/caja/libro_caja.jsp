<%@ page errorPage="../error.jsp"%>
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
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />

<%
/**
==================================================================================================================
==================================================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

SQL2BeanBuilder sbb = new SQL2BeanBuilder();
ArrayList al = new ArrayList();
CommonDataObject cdo = new CommonDataObject();

String key = "";
String sql = "";
String mode = request.getParameter("mode");
String fg = request.getParameter("fg");

if(fg==null) fg = "anio";

boolean viewMode = false;
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy");
String mTime = CmnMgr.getCurrentDate("hh12:mi:ss am");
String fecha = request.getParameter("fecha");
if(fecha==null) fecha = cDateTime;
int lineNo = 0;
if (mode == null) mode = "add";
if (request.getMethod().equalsIgnoreCase("GET"))
{
	sql = "select (select nombre from tbl_sec_compania where codigo = "+(String) session.getAttribute("_companyId")+") nombre_compania, (select ano from tbl_con_estado_anos where cod_cia = "+(String) session.getAttribute("_companyId")+" and estado = 'ACT') anio from dual";
	if(fg.equals("mes")) sql = "select (select nombre from tbl_sec_compania where codigo = "+(String) session.getAttribute("_companyId")+") nombre_compania, (select mes||' / '||ano from tbl_con_estado_meses where cod_cia = "+(String) session.getAttribute("_companyId")+" and estatus = 'ACT') anio from dual";	
	cdo = SQLMgr.getData(sql);
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<%@ include file="../common/tab.jsp" %>
<script language="javascript">
document.title = 'CXC - '+document.title;

function doSubmit(value){document.form1.baction.value = value;}
function doAction(){}
function eject(accion){	
	var p_compania = '<%=(String) session.getAttribute("_companyId")%>';
	var v_user = '<%=(String) session.getAttribute("_userName")%>';
	var clientIdentifier = '<%=ConMgr.getClientIdentifier()%>';
	var fecha	= document.form1.fecha.value;
	var fechaIni	= document.form1.fechaIni.value;
	var fechaFin	= document.form1.fechaFin.value;
	var count =0;
	var msg2='';
	var v_tipo =4;
	
	if(accion=='CM')
	{
		if(fecha == '') alert('Los parámetros no están completos...,VERIFIQUE!');
		else
		{
				count=getDBData('<%=request.getContextPath()%>','count(*)','tbl_con_replibros','compania='+p_compania+' and nvl(comprobante,\'N\')= \'S\' and  trunc(fecha)=to_date(\''+fecha+'\',\'dd/mm/yyyy\')','');
		
			if(count == 0)
			{
				count=getDBData('<%=request.getContextPath()%>','count(*)','tbl_con_replibros','compania='+p_compania+' and  trunc(fecha)=to_date(\''+fecha+'\',\'dd/mm/yyyy\')','');
				if(count == 0)
				{
				 	msg2 = '¿Desea generar el libro para esta fecha?';
				}else msg2 = '¿Desea generar nuevamente el libro para esta fecha?';	
				if(confirm(msg2))
				{
					showPopWin('../common/run_process.jsp?fp=COMP&actType=58&docType=GENCOMP&docId=LIBCJA&docNo=LIBCJA&tipo='+v_tipo+'&fechaIni='+fecha+'&fechaFin='+fecha+'&compania=<%=(String) session.getAttribute("_companyId")%>',winWidth*.75,winHeight*.50,null,null,'');
				}else alert('Proceso Cancelado');
			}else alert('Libro de caja para ese día ya tiene comprobante generado, verifique');
		 }
	}
	else if(accion=='CL')
	{
			if(confirm('¿Esta seguro de generar el comprobante?'))
			{
				showPopWin('../common/run_process.jsp?fp=COMP&actType=59&docType=GENCOMP&docId=COMPCJA&docNo=COMPCJA&tipo='+v_tipo+'&fechaIni='+fecha+'&fechaFin='+fechaFin+'&compania=<%=(String) session.getAttribute("_companyId")%>',winWidth*.75,winHeight*.50,null,null,'');
			}else alert('Proceso Cancelado');
	
	}
	else if(accion=='CO')
	{
		abrir_ventana('../caja/libro_caja_detail.jsp?xDate='+fechaIni+'&toDate='+fechaFin);
	}
	else if(accion=='RE')
	{
		abrir_ventana('../caja/print_depositos_x_cajas.jsp?xDate='+fecha);
	}
	else if(accion=='AL')
	{	
	}
}


</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" bgcolor="#fafbfa" onLoad="javascript:doAction()">
<jsp:include page="../common/title.jsp" flush="true">
<jsp:param name="title" value="Generar Comprobante"></jsp:param>
</jsp:include>
<table align="center" width="75%" cellpadding="0" cellspacing="0">
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
                    <%=fb.hidden("banco","")%>
										<%=fb.hidden("fg",fg)%>
										<%=fb.hidden("clearHT","")%>
                    <tr>
                      <td><table width="100%" cellpadding="1" cellspacing="1">
                          <tr class="TextPanel" align="center">
                            <td colspan="3">
                            <cellbytelabel>Generacion de Libro de caja</cellbytelabel>
                            </td>
                          </tr>	
                           <tr class="TextPanel" align="center">
                            <td colspan="2">
                            <cellbytelabel>Procesos</cellbytelabel>
                            </td>
                            <td>
                            <cellbytelabel>Reportes</cellbytelabel>
                            </td>
                          </tr>	
                          <tr class="TextHeader01">
                            <td width="40%"><cellbytelabel>Fecha</cellbytelabel>
                            <jsp:include page="../common/calendar.jsp" flush="true">
                            <jsp:param name="noOfDateTBox" value="1" />
                            <jsp:param name="nameOfTBox1" value="fecha" />
                            <jsp:param name="valueOfTBox1" value="<%=cDateTime%>" />
                            <jsp:param name="fieldClass" value="text10" />
                            <jsp:param name="buttonClass" value="text10" />
                            </jsp:include>
                            </td>
                            <td width="25%">
							<%=fb.button("libro","Generar Libro",false,false,"text10","","onClick=\"javascript:eject('CM');\"")%>
							<%=fb.button("corre","Ver Libro",false,false,"text10","","onClick=\"javascript:eject('CO');\"")%>
 							<%//=fb.button("a_libro","Anular Libro",false,false,"text10","","onClick=\"javascript:eject('AL');\"")%>
            
                                                
														
                            </td>
                            <td width="25%" rowspan="2">
                             <%=fb.button("reporte","Detallado x Caja",false,false,"text10","","onClick=\"javascript:eject('RE');\"")%>
                            </td>
                          </tr>
                          
                          
                           <tr class="TextHeader01">
                            <td>
                            <jsp:include page="../common/calendar.jsp" flush="true">
                            <jsp:param name="noOfDateTBox" value="2" />
                            <jsp:param name="nameOfTBox1" value="fechaIni" />
                            <jsp:param name="valueOfTBox1" value="<%=cDateTime%>" />
                            <jsp:param name="nameOfTBox2" value="fechaFin" />
                            <jsp:param name="valueOfTBox2" value="<%=cDateTime%>" />
                            <jsp:param name="fieldClass" value="text10" />
                            <jsp:param name="buttonClass" value="text10" />
                            </jsp:include>
                            </td>
                            <td>
									<%=fb.button("comp","Comprobantes",false,false,"text10","","onClick=\"javascript:eject('CL');\"")%>
                                                
														
                            </td>
                            
                          </tr>
                         
                          <tr class="textRow01">
                            <td colspan="3">&nbsp;</td>
                          </tr>
                          <tr class="textRow01" align="center">
                            <td colspan="3"></td>
                          </tr>
                          <!--<tr class="TextPanel" align="center">
                            <td colspan="2">
                            REPORTES
                            </td>
                          </tr>	
                          <tr class="textRow01" align="center">
                            <td colspan="2">
												<%=fb.button("detallado","Detallado por cajera",false,false,"text10","","onClick=\"javascript:eject('CM');\"")%>
												<%=fb.button("resumido","Resumido",false,false,"text10","","onClick=\"javascript:eject('CM');\"")%>
                                                pendiente 'CJA71010.RDF'.
                                                'CJA71000.RDF'.	
                            </td>
                          </tr>
                          -->
                            
                        </table></td>
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
