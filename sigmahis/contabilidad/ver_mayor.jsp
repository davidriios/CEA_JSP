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
String anio = request.getParameter("anio");
String mes = request.getParameter("mes");
String fechaini = request.getParameter("fechaini");
String fechafin = request.getParameter("fechafin");
String cta1 = request.getParameter("cta1");
String cta2 = request.getParameter("cta2");
String cta3 = request.getParameter("cta3");
String cta4 = request.getParameter("cta4");
String cta5 = request.getParameter("cta5");
String cta6 = request.getParameter("cta6");
String num_cta = request.getParameter("num_cta");
String filtrado_por = request.getParameter("filtrado_por");

if(fg==null) fg = "";
if(fp==null) fp = "";
if(anio==null) anio = "";
if(mes==null) mes = "";
if(fechaini==null) fechaini = "";
if(fechafin==null) fechafin = "";
if(filtrado_por == null) filtrado_por = "M";

boolean viewMode = false;
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy");
if(anio.equals("") && mes.equals("")){
	mes = cDateTime.substring(3, 5);
}
String mTime = CmnMgr.getCurrentDate("hh12:mi:ss am");
String fecha = request.getParameter("fecha");
if(fecha==null) fecha = cDateTime;
int lineNo = 0;
if (mode == null) mode = "add";
if (request.getMethod().equalsIgnoreCase("GET"))
{
	sql = "select ano anio, to_char(fecha_inicio, 'dd/mm/yyyy') fechaini, nvl(to_char(fecha_cierre, 'dd/mm/yyyy'), '31/12/'||to_char(sysdate, 'yyyy')) fechafin from tbl_con_estado_anos where cod_cia = "+(String) session.getAttribute("_companyId") + " and estado = 'ACT'";
	cdo = SQLMgr.getData(sql);

	sql = "select descripcion from tbl_con_catalogo_gral where compania = " + (String) session.getAttribute("_companyId") + " and cta1 = '"+cta1+"' and cta2 = '"+cta2+"' and cta3 = '"+cta3+"' and cta4 = '"+cta4+"' and cta5 = '"+cta5+"' and cta6 = '" + cta6 + "'";
	cdoT = SQLMgr.getData(sql);

	if(fechaini.equals("") && fechafin.equals("")){
		anio = cdo.getColValue("anio");
		fechaini = cdo.getColValue("fechaini");
		fechafin = cdo.getColValue("fechafin");
	}
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<script language="javascript">
document.title = 'CONTABILIDAD - '+document.title;

function setValues(){
	var filtrado_por = document.form1.filtrado_por.value;
	var anio = document.form1.anio.value;
	var mes = document.form1.mes.value;
	var fechaini = document.form1.fechaini.value;
	var fechafin = document.form1.fechafin.value;
	var tipoReg = document.form1.tipo_reg.value;
	var tipoComprob = document.form1.tipoComprob.value;
	var resumen = '';
	if(document.form1.resumen.checked==true)resumen='S';
	
	if(filtrado_por=='M'){
		$("#anio, #mes").prop("disabled", false);
	    $("#fechaini, #fechafin, [name='resetfechaini'],[name='resetfechafin'] ").prop("disabled", true);
		window.frames['itemFrame'].location = '../contabilidad/ver_mayor_det.jsp?anio='+anio+'&mes='+mes+'&cta1=<%=cta1%>&cta2=<%=cta2%>&cta3=<%=cta3%>&cta4=<%=cta4%>&cta5=<%=cta5%>&cta6=<%=cta6%>&num_cta=<%=num_cta%>&fg=<%=fg%>&tipoReg='+tipoReg+'&resumen='+resumen+'&tipoComprob='+tipoComprob;
	}
	else {
	    $("#fechaini, #fechafin, [name='resetfechaini'],[name='resetfechafin'] ").prop("disabled", false);
	    $("#anio, #mes").prop("disabled", true);
		window.frames['itemFrame'].location = '../contabilidad/ver_mayor_det.jsp?cta1=<%=cta1%>&cta2=<%=cta2%>&cta3=<%=cta3%>&cta4=<%=cta4%>&cta5=<%=cta5%>&cta6=<%=cta6%>&fechaini='+fechaini+'&fechafin='+fechafin+'&num_cta=<%=num_cta%>&anioSaldoIni=<%=anio%>&fg=<%=fg%>&tipoReg='+tipoReg+'&resumen='+resumen+'&tipoComprob='+tipoComprob;
	}
}

function ctrlParams(inObj,pattern){
  var __isAselect = inObj.is("select");
  var __isATextBox = inObj.is("input");
  console.log("__isAselect = "+__isAselect)
  console.log("__isATextBox = "+__isATextBox)
}

function printMayorGeneral()
{
	var filtrado_por = document.form1.filtrado_por.value;
	var anio = document.form1.anio.value;
	var mes = document.form1.mes.value;
	var fechaini = document.form1.fechaini.value;
	var fechafin = document.form1.fechafin.value;
	var tipoReg = document.form1.tipo_reg.value;
	var tipoComprob = document.form1.tipoComprob.value;
    var resumen = '';
	if(document.form1.resumen.checked==true)resumen='S';

	if(filtrado_por=='M'){
		abrir_ventana('../contabilidad/print_mayor_general.jsp?anio='+anio+'&mes='+mes+'&cta1=<%=cta1%>&cta2=<%=cta2%>&cta3=<%=cta3%>&cta4=<%=cta4%>&cta5=<%=cta5%>&cta6=<%=cta6%>&num_cta=<%=num_cta%>&tipoReg='+tipoReg+'&resumen='+resumen+'&tipoComprob='+tipoComprob);
	}
	else {
		abrir_ventana('../contabilidad/print_mayor_general.jsp?cta1=<%=cta1%>&cta2=<%=cta2%>&cta3=<%=cta3%>&cta4=<%=cta4%>&cta5=<%=cta5%>&cta6=<%=cta6%>&fechaini='+fechaini+'&fechafin='+fechafin+'&num_cta=<%=num_cta%>&anioSaldoIni=<%=anio%>&tipoReg='+tipoReg+'&resumen='+resumen+'&tipoComprob='+tipoComprob);
	}

}

function doAction(){setValues();}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" bgcolor="#fafbfa" onLoad="doAction()">
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
                    <tr>
                      <td><table width="100%" cellpadding="1" cellspacing="0">
                      		<tr>
                          <td colspan="2" align="right">
                          <a href="javascript:printMayorGeneral()" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')"><font class="RedTextBold"> Imprimir Mayor General</font></a>
</td>
                          </tr>
                          <tr class="TextPanel">
                            <td colspan="2">Periodo:
                            Filtro por:
														<%=fb.select("filtrado_por","M=AÑO/MES,RF=RANGO FECHA",filtrado_por,false,false,0,"Text10",null,"onchange=setValues()")%>
														<%=fb.select(ConMgr.getConnection(),"select ano, ano||'-'||estado||'-'||to_char(fecha_inicio, 'dd/mm/yyyy')||'-'||to_char(fecha_cierre, 'dd/mm/yyyy') descripcion from tbl_con_estado_anos where cod_cia = "+(String) session.getAttribute("_companyId") + "order by estado, ano desc","anio",anio,false,false,0, "text10", "", "onchange=setValues()")%>
                            Mes:
                            <%=fb.select("mes","01=Ene,02=Feb,03=Mar,04=Abr,05=May,06=Jun,07=Jul,08=Ago,09=Sep,10=Oct,11=Nov,12=Dic,13=CIERRE",mes,false,false,0,"Text10",null,"onchange=setValues()")%>
                            <jsp:include page="../common/calendar.jsp" flush="true">
                            <jsp:param name="noOfDateTBox" value="2" />
                            <jsp:param name="clearOption" value="true" />
                            <jsp:param name="nameOfTBox1" value="fechaini" />
                            <jsp:param name="valueOfTBox1" value="<%=fechaini%>" />
                            <jsp:param name="nameOfTBox2" value="fechafin" />
                            <jsp:param name="valueOfTBox2" value="<%=fechafin%>" />
                            <jsp:param name="fieldClass" value="text10" />
                            <jsp:param name="buttonClass" value="text10" />
                            </jsp:include>&nbsp;Tipo Reg.<%=fb.select("tipo_reg","SP=PROCESO AUTOMATICO,RCM=REGISTRADO MANUAL,RP=REGISTROS DE PLANILLA,X=ORIGEN DESCONOCIDO","",false,false,0,"Text10",null,"onchange=setValues()","","T")%><%=fb.checkbox("resumen","S",false,false,null,null,"")%> Res. 
							<br>
							<%=fb.select(ConMgr.getConnection(), "select codigo_comprob,codigo_comprob||' - '||substr(descripcion,1,65) as descripcion from tbl_con_clases_comprob where tipo='C'","tipoComprob","",false,false,0,"Text10",null,null,null,"S")%>

                      			<%=fb.button("ir","Ir",true,false,"","","onClick=\"javascript:setValues();\"")%>
                            </td>
                          </tr>
                          <tr class="TextHeader02" height="21">
                            <td>Cuenta:&nbsp;&nbsp;<%=cta1%>.<%=cta2%>.<%=cta3%>.<%=cta4%>.<%=cta5%>.<%=cta6%></td>
                            <td>Nombre:&nbsp;&nbsp;<%=cdoT.getColValue("descripcion")%></td>
                          </tr>
                        </table></td>
                    </tr>
                    <tr>
                      <td><iframe name="itemFrame" id="itemFrame" frameborder="0" align="center" width="100%" height="300" scrolling="yes" src=""></iframe></td>
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
</body>
</html>
<%
}//GET
%>
