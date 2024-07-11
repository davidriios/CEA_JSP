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
String cia = (String) session.getAttribute("_companyId");
String usuario = (String) session.getAttribute("_userName");

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
	window.frames['itemFrame'].document.form.baction.value = value;
	window.frames['itemFrame'].doSubmit(value);
}


function doAction(){
	//	setTextValues();
	//setHeight('itemFrame',document.body.scrollHeight);
}

function imprimir(){
	abrir_ventana('../inventario/print_list_articulos_axa.jsp');
}





function ejecutar()
{
var mes=document.form1.mes.value;
var anio = document.form1.anio.value;
var periodo = document.form1.periodo.value;
var quincena = document.form1.quincena.value;
var desde = document.form1.desde.value;
var hasta = document.form1.hasta.value;
var cierre = document.form1.cierre.value;
var grupo = document.form1.grupo.value;
var user = document.form1.usuario.value;
var unidad = document.form1.unidad.value;
var empId = "";

	if (grupo=="") grupo = "null";

	if(confirm('Está seguro que desea Generar la Distribución de Ausencias y Tardanzas ?...'))
		{
		showPopWin('../common/run_process.jsp?fp=DISTTRX&actType=50&docType=DISTTRX&fechaIni='+desde+'&fechaFin='+hasta+'&compania=<%=(String) session.getAttribute("_companyId")%>&ubicacion='+unidad+'&grupo='+grupo+'&anio='+anio+'&periodo='+periodo+'&usuario='+user,winWidth*.75,winHeight*.65,null,null,'');	
		}
}

function ejecutar_old()
{
var mes=document.form1.mes.value;
var anio = document.form1.anio.value;
var periodo = document.form1.periodo.value;
var quincena = document.form1.quincena.value;
var desde = document.form1.desde.value;
var hasta = document.form1.hasta.value;
var cierre = document.form1.cierre.value;
var grupo = document.form1.grupo.value;
var user = document.form1.usuario.value;
var unidad = document.form1.unidad.value;

	if (grupo=="") grupo = "null";

	if(confirm('Está seguro que desea Generar la Distribución de Ausencias y Tardanzas ?...'))
		{
			if(executeDB('<%=request.getContextPath()%>','delete from tbl_pla_temporal_asistencia where compania = <%=cia%> and ue_codigo = nvl(\''+grupo+'\',ue_codigo) ','tbl_pla_temporal_asistencia'))
			if(executeDB('<%=request.getContextPath()%>','call sp_pla_cargar_ausencias( \''+desde+'\', \''+hasta+'\',<%=cia%>,'+grupo+',\''+user+'\')'));
				if(executeDB('<%=request.getContextPath()%>','call sp_pla_cargar_incapacidad( \''+desde+'\', \''+hasta+'\',<%=cia%>,'+grupo+',\''+user+'\')'));
					if(executeDB('<%=request.getContextPath()%>','call sp_pla_cargar_permisos( \''+desde+'\', \''+hasta+'\',<%=cia%>,'+grupo+',\''+user+'\')'));
						if(executeDB('<%=request.getContextPath()%>','call sp_pla_cargar_tardanzas( \''+desde+'\', \''+hasta+'\',<%=cia%>,'+grupo+',\''+unidad+'\')'));
							if(executeDB('<%=request.getContextPath()%>','call sp_pla_asignar_turno( \''+desde+'\', \''+hasta+'\',<%=cia%>,'+grupo+',\''+unidad+'\')'));
								if(executeDB('<%=request.getContextPath()%>','call sp_pla_distribucion_aus( \''+desde+'\', \''+hasta+'\',<%=cia%>,'+grupo+',\''+unidad+'\')'));
									if(executeDB('<%=request.getContextPath()%>','call sp_pla_descuento_x_ajuste( \''+desde+'\', \''+hasta+'\',<%=cia%>,'+grupo+',\''+unidad+'\')'));
										if(executeDB('<%=request.getContextPath()%>','call sp_pla_devolucion_distribucion( \''+desde+'\', \''+hasta+'\',<%=cia%>,'+grupo+',\''+unidad+'\')'));
		//eval('document.form1.del').disabled = false;
		alert('Proceso se realizó Satisfactoriamente....  Desde: '+desde+'      hasta: '+hasta);

		}
}

function reversar()
{
var mes=document.form1.mes.value;
var anio = document.form1.anio.value;
var periodo = document.form1.periodo.value;
var quincena = document.form1.quincena.value;
var desde = document.form1.desde.value;
var hasta = document.form1.hasta.value;
var cierre = document.form1.cierre.value;
var grupo = document.form1.grupo.value;
var user = document.form1.usuario.value;
var unidad = document.form1.unidad.value;
var flag = "DELTRX";

if (grupo=="") grupo = "null";

showPopWin('../common/run_process.jsp?fp=DELTRX&actType=54&docType=DELTRX&fechaIni='+desde+'&fechaFin='+hasta+'&grupo='+grupo+'&compania=<%=(String) session.getAttribute("_companyId")%>&flag='+flag,winWidth*.75,winHeight*.65,null,null,'');	
}

function reversar_old()
{
var mes=document.form1.mes.value;
var anio = document.form1.anio.value;
var periodo = document.form1.periodo.value;
var quincena = document.form1.quincena.value;
var desde = document.form1.desde.value;
var hasta = document.form1.hasta.value;
var cierre = document.form1.cierre.value;
var grupo = document.form1.grupo.value;
var user = document.form1.usuario.value;
var unidad = document.form1.unidad.value;

if (grupo=="") grupo = "";
if(confirm('Está seguro que desea Eliminar la Distribución de Ausencias y Tardanzas ?...'))
		{
if(executeDB('<%=request.getContextPath()%>','delete from tbl_pla_at_det_dist where compania = <%=cia%> and to_date(to_char(fecha,\'dd/mm/yyyy\'),\'dd/mm/yyyy\')=to_date(\''+desde+'\',\'dd/mm/yyyy\') and to_date(to_char(fecha,\'dd/mm/yyyy\'),\'dd/mm/yyyy\')=to_date(\''+hasta+'\',\'dd/mm/yyyy\') and (trx_generada = \'N\'  or trx_generada is null ) and ue_codigo = nvl(\''+grupo+'\',ue_codigo) ','tbl_pla_at_det_dist'))

if(executeDB('<%=request.getContextPath()%>','delete from tbl_pla_temporal_asistencia where compania = <%=cia%> and ue_codigo = nvl(\''+grupo+'\',ue_codigo) ','tbl_pla_temporal_asistencia'))
//eval('document.form1.del').disabled = true;
alert('Proceso Eliminó Transacciones Generadas....  Desde: '+desde+'     hasta: '+hasta);
} }
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" bgcolor="#fafbfa" onLoad="javascript:doAction()">
<jsp:include page="../common/title.jsp" flush="true">
<jsp:param name="title" value="GENERACION DE AUSENCIAS"></jsp:param>
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
					<%=fb.hidden("unidad","")%>
                    <%=fb.hidden("fecha_final","")%>
                    <%=fb.hidden("finicio","")%>
                    <%=fb.hidden("ffinal","")%>
                    <%=fb.hidden("num_periodo","")%>
		    <%=fb.hidden("usuario",usuario)%>
                    <tr>
                      <td><table width="100%" cellpadding="1" cellspacing="0">
                          <tr class="TextPanel">
                            <td colspan="2">&nbsp;Parámetros para Generación de Ausencias </td>
                          </tr>

                          <tr class="TextRow01" align="right">

                            <td colspan="2">&nbsp; Fecha Cierre :
														<%=fb.textBox("cierre",cierre,true,false,true,10,"text10","","")%>
														&nbsp;&nbsp;</td>
                          </tr>

													 <tr class="TextRow01">
													  <td>&nbsp;
                            No. Periodo :
														<%=fb.textBox("periodo",cdo.getColValue("periodo"),true,false,true,4,"text10","","")%>
														&nbsp;&nbsp; Año :
														<%=fb.textBox("anio",anio,true,false,true,4,"text10","","")%>
                            &nbsp; &nbsp;Mes :
														<%=fb.textBox("mes",mes,true,false,true,14,"text10","","")%>
														&nbsp;&nbsp; Quincena :
														<%=fb.textBox("quincena",quincena,true,false,true,14,"text10","","")%>
													  </td>
                            <td align="right">&nbsp;Fecha Inicio :
														<%=fb.textBox("desde",cdo.getColValue("desde"),true,false,true,10,"text10","","")%>
														&nbsp;&nbsp;
														</td>
                          </tr>
													 <tr class="TextRow01" align="right">
                            <td colspan="2">&nbsp;Fecha Final :
														<%=fb.textBox("hasta",cdo.getColValue("hasta"),true,false,true,10,"text10","","")%>
														&nbsp;&nbsp;
														</td>
                          </tr>

                          <tr class="TextRow01">
                            <td colspan="2" align="center">&nbsp;
                            Unidad a Generar :
                           	<%=fb.select(ConMgr.getConnection(),"select codigo as grupo,  codigo||'-'||descripcion descripcion, codigo from tbl_pla_ct_grupo where compania="+(String) session.getAttribute("_companyId")+" order by 1","grupo","",false,false,0,"",null,null,null,"")%>
                            </td>
                          </tr>

													<tr>
													 <td class="2">&nbsp;</td>
													</tr>
													 <tr class="TextRow01">
                            <td colspan="2" align="center">&nbsp;
										 				<authtype type='50'><%=fb.button("ir","  EJECUTAR PROCESO PARA GENERARAR AUSENCIAS Y TARDANZAS  ",false,false,"Text10","","onClick=\"javascript:ejecutar();\"")%></authtype>

                            </td>

                          </tr>
													<tr class="TextRow02">
                            <td colspan="2" align="center">&nbsp;
										 				<authtype type='51'><%=fb.button("del","ELIMINAR DISTRIBUCION DE AUSENCIAS Y TARDANZAS GENERADAS",false,false,"Text10","","onClick=\"javascript:reversar();\"")%></authtype>

                            </td>

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
else
{
	String saveOption = request.getParameter("saveOption");//N=Create New,O=Keep Open,C=Close
	String errCode = "";
	String errMsg = "";
	fp = request.getParameter("fp");
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
