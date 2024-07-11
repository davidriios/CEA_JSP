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
======================================================================================================================================================
======================================================================================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy");
String fg = request.getParameter("fg");
String agrupa_hon = request.getParameter("agrupa_hon");
if(fg==null) fg="";
if(agrupa_hon==null) agrupa_hon = "";
if (request.getMethod().equalsIgnoreCase("GET"))
{
	CommonDataObject cd = new CommonDataObject();
	if(agrupa_hon.equals("")){
		
		cd = SQLMgr.getData("select get_sec_comp_param("+(String) session.getAttribute("_companyId")+", 'LIQ_RECL_AGRUPAR_HON') agrupa_hon, get_sec_comp_param("+(String) session.getAttribute("_companyId")+", 'COD_BANCO_GENERAL') cod_banco_general, get_sec_comp_param("+(String) session.getAttribute("_companyId")+", 'COD_BANCO_BANISTMO') cod_banco_banistmo from dual");
		agrupa_hon = cd.getColValue("agrupa_hon");
	}

%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<%@ include file="../common/tab.jsp" %>
<script language="javascript">
document.title = 'CXP - '+document.title;
function eject(value){
	var accion = getRadioButtonValue(document.form1.accion);
	//var fecha_desde=document.form1.fecha_desde.value;
	var fecha_hasta=document.form1.fecha_hasta.value;
	var banco = document.form1.cod_banco.value;
	var cod_banco_general = '<%=cd.getColValue("cod_banco_banistmo")%>';
	var cod_banco_banistmo = '<%=cd.getColValue("cod_banco_banistmo")%>';
	var vista = getSelectedOptionTitle(document.form1.cod_banco,'');
	var no_lista = (document.form1.no_lista)?document.form1.no_lista.value:'';
	var rehacer = (document.form1.rehacer)?document.form1.rehacer.value:'';
	if(banco !='' && fecha_hasta !=''){
			if((banco==cod_banco_general && accion=='T') || (banco==cod_banco_banistmo && accion =='C')){ if(confirm('Está seguro que sea generar el archivo!')){showPopWin('../planmedico/generate_file.jsp?fp=ACHTC&docType=ACHTC&banco='+banco+'&fHasta='+fecha_hasta+'&tipo='+accion+'&vista='+vista+'&no_lista='+no_lista+'&rehacer='+rehacer,winWidth*.75,winHeight*.65,null,null,'');}} else alert('Opcion no disponible para Banco seleccionado!'); 
		} else alert('Seleccione banco  ó introduzca rango de fecha valido.');
}
var xHeight=0;
function doAction(){xHeight=objHeight('_tblMain');resizeFrame();}
function resizeFrame(){}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" bgcolor="#fafbfa" onLoad="javascript:doAction()">
<jsp:include page="../common/title.jsp" flush="true">
<jsp:param name="title" value="Generar ACH"></jsp:param>
</jsp:include>
<table align="center" width="50%" cellpadding="0" cellspacing="0"  id="_tblMain">
  <tr>
    <td class="TableBorder"><table align="center" width="100%" cellpadding="5" cellspacing="0">
        <tr>
          <td class="TableBorder"><table align="center" width="100%" cellpadding="5" cellspacing="0">
              <tr>
                <td><table align="center" width="100%" cellpadding="0" cellspacing="1">
                    <!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
                    <%fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
                    <%=fb.formStart(true)%>
                    <tr>
                      <td><table width="100%" cellpadding="1" cellspacing="0">
                          <tr class="TextPanel">
                            <td colspan="2">
                            <cellbytelabel>Generaci&oacute;n de Archivo ACH/Tarjeta de credito</cellbytelabel>
                            </td>
                          </tr>	
                          <tr class="TextHeader01">
                            <td colspan="2"><cellbytelabel>1. Seleccione el Banco</br>
				2. Introduzca el rango de fecha de las transacciones</br>
				3. Seleccione el tipo de archivo a generar</br>
				4. Presione el bot&oacute;n de Ejecutar</cellbytelabel></td>
                          </tr>
                          <tr class="TextHeader02">
                            <td colspan="2">Fecha Hasta:
                            <jsp:include page="../common/calendar.jsp" flush="true">
                            <jsp:param name="noOfDateTBox" value="1" />
                            <jsp:param name="nameOfTBox1" value="fecha_hasta" />
                            <jsp:param name="valueOfTBox1" value="<%=cDateTime%>" />
                            <jsp:param name="fieldClass" value="text10" />
                            <jsp:param name="buttonClass" value="text10" />
                            </jsp:include>
                            </td>
                          </tr>
													<tr class="TextHeader02">
													<td colspan="2"><cellbytelabel>Banco</cellbytelabel>:<%=fb.select(ConMgr.getConnection(),"select ruta_Transito, nombre || ' - ' ||(select substr(cuenta_banco, length(cuenta_banco)-3) from tbl_con_cuenta_bancaria where cod_banco = b.cod_banco and compania = b.compania and rownum = 1) nombre,vista from tbl_con_banco b where compania="+(String) session.getAttribute("_companyId")+" order by 2","cod_banco","",false,false,0,"Text10",null,null,null,"")%></td>
													</tr>
													<tr class="TextHeader02">
                            <td width="65%">
                            <%=fb.radio("accion", "T", true, false, false,"text10","","")%>&nbsp;<cellbytelabel>TARJETA DE CREDITO</cellbytelabel>
                            </td>
                            <td>&nbsp;</td>
                          </tr>
                          <tr class="TextHeader02">
                            <td width="65%">
                            <%=fb.radio("accion", "C", false, false, false,"text10","","")%>&nbsp;<cellbytelabel>ACH</cellbytelabel>
                            </td>
                            <td>&nbsp;</td>
                          </tr>
						   <tr class="TextHeader01">
                          	<td colspan="2"  align="center">
														<%if(UserDet.getUserProfile().contains("0")){%>
														No. Lista:
														<%=fb.textBox("no_lista","",false,false,false,10)%>
														Rehacer archivo?
														<%=fb.select("rehacer","S=SI,N=NO", "N", "")%>
														<%}%>
														<authtype type='50'><%=fb.button("add","Ejecutar",false,false,"text10","","onClick=\"javascript:eject(this.value);\"")%></authtype></td>
						  </tr>
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
