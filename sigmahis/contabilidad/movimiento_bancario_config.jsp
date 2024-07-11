<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder"%>

<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="cdo" scope="page" class="issi.admin.CommonDataObject" />
<%
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
//if (!(SecMgr.checkAccess(session.getId(),"0")|| SecMgr.checkAccess(session.getId(),"500042")|| SecMgr.checkAccess(session.getId(),"500043")|| SecMgr.checkAccess(session.getId(),"500044"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);
SQL2BeanBuilder sbb = new SQL2BeanBuilder();

ArrayList al = new ArrayList();
ArrayList lista = new ArrayList();
String mode = request.getParameter("mode");
String cuenta = request.getParameter("cuenta");
String banco = request.getParameter("banco");
String mes = request.getParameter("mes");
String cons = request.getParameter("cons");
String anio = request.getParameter("anio");
String nombre = request.getParameter("nombre");
String sql="";
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy");
int mesCont =0;
if(anio == null)anio=cDateTime.substring(6,10);

if (mode == null) mode = "add";

if (request.getMethod().equalsIgnoreCase("GET"))
{
	if (mode.equalsIgnoreCase("add"))
	{
	cdo.addColValue("consecutivo","0");
	cdo.addColValue("nombre",request.getParameter("nombre"));
	cdo.addColValue("cuenta",request.getParameter("cuenta"));
	cdo.addColValue("fecha",fecha);
	cdo.addColValue("anio",anio);
	}
	else
	{
		if (cuenta == null) throw new Exception("La Cuenta Bancaria a Procesar no es válida. Por favor intente nuevamente!");


	  sql = "SELECT a.banco, a.cuenta_banco cuenta, nvl(a.monto_retenido,0) monto, a.revertido, a.aprobado, a.observacion, a.tipo_movimiento lado, a.consecutivo_ag deposito, to_char(a.f_movimiento,'dd/mm/yyyy') fecha, a.num_cheque cheque, a.consecutivo, a.anio, a.tipo_documento tipo, '[ ' ||a.tipo_documento || ' ] ' ||b.descripcion documento FROM tbl_con_saldo_bancario_f a, tbl_con_sb_tipo_documento b WHERE a.tipo_documento = b.tipo_documento and a.cuenta_banco='"+cuenta+"' and a.banco='"+banco+"' and a.consecutivo = "+cons+" and a.compania="+(String) session.getAttribute("_companyId")+" order by a.consecutivo, a.tipo_documento ";

		cdo = SQLMgr.getData(sql);
		cdo.addColValue("nombre",request.getParameter("nombre"));
	}
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
</head>
<script language="javascript">
<%if (mode.equalsIgnoreCase("add")){%>
document.title=" Movimiento de Saldo Bancario Agregar - "+document.title;
<%}else if (mode.equalsIgnoreCase("edit")){%>
document.title="Movimiento de Saldo Bancario Edición - "+document.title;
<%}%>

function addBanco()
{
  abrir_ventana2('../contabilidad/saldobank_cta_list.jsp?id=1');
}
function doAction()
{
	
}
function checkMes()
{
	var banco = document.form1.bancoCode.value;
	var cuenta = document.form1.cuentaCode.value;
	var anio = document.form1.anio.value;
	
	var v_mes = getDBData('<%=request.getContextPath()%>','nvl(max(mes),0)+1','tbl_con_sb_saldos','cod_banco = \''+banco+'\' and cuenta_banco = \''+cuenta+'\' and anio = '+anio+' and compania = <%=(String) session.getAttribute("_companyId")%>','');

	if(v_mes ==13)
	{
		alert('Ya están todos los meses completos, verifique...');
		return false;
	
	}else return true;
	

}
function dateCk()
{
    var size;
	var fechaValue;
	var banco;
	var cuenta;
	var cont=0;
	var msg = '';
	
	banco = document.form1.bancoCode.value;
	cuenta = document.form1.cuentaCode.value;
	fechaValue = document.form1.fecha.value;

	if(fechaValue == '')  msg = ' una Fecha ';
	if (msg == '')
	{
	 if(hasDBData('<%=request.getContextPath()%>','tbl_con_sb_saldos','compania=<%=(String) session.getAttribute("_companyId")%> and cod_banco=\''+banco+'\' and cuenta_banco=\''+cuenta+'\' and mes=to_number(to_char(to_date(\''+fechaValue+'\',\'dd/mm/yyyy\'),\'MM\')) and estatus in (\'C\',\'I\') and anio=to_number(to_char(to_date(\''+fechaValue+'\',\'dd/mm/yyyy\'),\'YYYY\'))',''))
	{
		alert('**EL MES ESTA CERRADO .....VERIFIQUE **!');
		document.form1.fecha.value='';
	}  else if(hasDBData('<%=request.getContextPath()%>','tbl_con_sb_saldos','compania=<%=(String) session.getAttribute("_companyId")%> and cod_banco=\''+banco+'\' and cuenta_banco=\''+cuenta+'\' and mes=to_number(to_char(to_date(\''+fechaValue+'\',\'dd/mm/yyyy\'),\'MM\')) and estatus=\'A\' and anio=to_number(to_char(to_date(\''+fechaValue+'\',\'dd/mm/yyyy\'),\'YYYY\'))',''))
	{
	cont++;
	} else alert('** EL MES NO ESTA ABIERTO....VERIFIQUE , DESEA CONTINUAR**!');
	} else alert('Seleccione '+msg);
}

</script>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="CONTABILIDAD - TRANSACCION"></jsp:param>
</jsp:include>

<table align="center" width="99%" cellpadding="0" cellspacing="0">
	<tr>
		<td class="TableBorder">
			<table align="center" width="99%" cellpadding="0" cellspacing="1">

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
			<%fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
			<%=fb.formStart(true)%>
			<%=fb.hidden("mode",mode)%>
		
			<tr>
				<td colspan="4">&nbsp;</td>
			</tr>
			<tr class="TextRow02">
				<td colspan="4">&nbsp;</td>
			</tr>	
            <%
			if (!mode.equalsIgnoreCase("add"))
			{
			%>
            <tr class="TextRow01">
				<td>Consecutivo </td>
				<td colspan="3"><%=fb.intBox("consecutivo",cdo.getColValue("consecutivo"),true,false,true,10)%></td>				
			</tr>
            <%
			}
			%>		
			<tr class="TextRow01">
				<td width="13%">Banco</td>
				<%=fb.hidden("bancoCode",banco)%>
				<%=fb.hidden("cuentaCode",cuenta)%>
                              
				<td width="39%"><%=fb.textBox("nombre",nombre,true,false,true,60)%></td>
				<td width="13%">Cuenta</td>
				<td width="35%"><%=fb.textBox("cuenta",cuenta,true,false,true,20)%></td>			
			</tr>							
			<tr class="TextRow01">
				<td>A&ntilde;o</td>
				<td><%=fb.intBox("anio",cdo.getColValue("anio"),true,false,false,5,4)%></td>
				<td>Fecha</td>
				<td><jsp:include page="../common/calendar.jsp" flush="true">
						<jsp:param name="noOfDateTBox" value="1" />
						<jsp:param name="nameOfTBox1" value="fecha" />
						<jsp:param name="valueOfTBox1" value="<%=cdo.getColValue("fecha")%>" />
                        <jsp:param name="jsEvent" value="dateCk()"/>
						<jsp:param name="readonly" value="<%=(!mode.trim().equalsIgnoreCase("add"))?"y":"n"%>"/>
						</jsp:include></td>
			</tr>
			<tr class="TextRow01">
				<td>Tipo de Documento</td>
				<td><%=fb.select(ConMgr.getConnection(),"select tipo_documento codigo,descripcion||' - '||tipo_documento descTipo from tbl_con_sb_tipo_documento order by 1","tipo",cdo.getColValue("tipo"),"S")%></td>								
				<td>Monto</td>
				<td><%=fb.decBox("monto",cdo.getColValue("monto"),false,false,false,20)%></td>
			</tr>
			<tr class="TextRow01">
				<td>Depósito</td>
				<td><%=fb.textBox("deposito",cdo.getColValue("deposito"),false,false,false,20)%></td>				
				<td>Cheque</td>
				<td><%=fb.textBox("cheque",cdo.getColValue("cheque"),false,false,false,20)%></td>
            </tr>	
            	<tr class="TextRow01">
				<td>Lado</td>
				<td><%=fb.select("lado","DB=DEBITO,CR=CREDITO",cdo.getColValue("lado"),"S")%></td>				
				<td>Ver</td>
				<td><%=fb.checkbox("aprobado","S",(cdo.getColValue("aprobado") != null && cdo.getColValue("aprobado").trim().equalsIgnoreCase("S")),false)%></td>
            </tr>	
            
             <tr class="TextRow01">
				<td>Observaci&oacute;n</td>
				<td colspan="3"><%=fb.textarea("observacion",cdo.getColValue("observacion"),false,false,false,45,5)%></td>
									
			</tr>			
			
            <tr class="TextRow02">
				<td colspan="4" align="right"> <%=fb.submit("save","Guardar",true,false)%>
				<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%></td>
			</tr>	
			
            <tr>
				<td colspan="4">&nbsp;</td>
			</tr>
				
				 <%=fb.formEnd(true)%>

<!-- ================================   F O R M   E N D   H E R E   ================================ -->

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
  cuenta = request.getParameter("cuentaCode");
  banco = request.getParameter("bancoCode");
  cons = request.getParameter("consecutivo");
  nombre = request.getParameter("nombre");
   
  cdo = new CommonDataObject();
  
  cdo.setTableName("tbl_con_saldo_bancario_f");    

  cdo.addColValue("anio",request.getParameter("anio"));
  cdo.addColValue("f_movimiento",request.getParameter("fecha"));
  cdo.addColValue("tipo_documento",request.getParameter("tipo"));
  cdo.addColValue("monto_retenido",request.getParameter("monto"));
   if (request.getParameter("deposito") != null)
  cdo.addColValue("consecutivo_ag",request.getParameter("deposito"));
   if (request.getParameter("cheque") != null)
  cdo.addColValue("num_cheque",request.getParameter("cheque"));
   if (request.getParameter("lado") != null)
  cdo.addColValue("tipo_movimiento",request.getParameter("lado"));
   if (request.getParameter("aprobado") != null)
  cdo.addColValue("aprobado",request.getParameter("aprobado"));
   if (request.getParameter("observacion") != null)
  cdo.addColValue("observacion",request.getParameter("observacion"));
  
  cdo.addColValue("usuario_modificacion",(String) session.getAttribute("_userName"));
  cdo.addColValue("fecha_modificacion",cDateTime);
	  
  if (mode.equalsIgnoreCase("add"))
  { 
    cdo.addColValue("banco",banco);   
    cdo.addColValue("cuenta_banco",cuenta);
    cdo.addColValue("anio",""+request.getParameter("anio"));
	cdo.addColValue("compania",(String) session.getAttribute("_companyId"));
    cdo.addColValue("usuario_creacion",(String) session.getAttribute("_userName"));
    cdo.addColValue("fecha_creacion",CmnMgr.getCurrentDate("dd/mm/yyyy hh24:mi:ss"));
	cdo.setAutoIncWhereClause("compania="+(String) session.getAttribute("_companyId")+" and cuenta_banco='"+cuenta+"' and banco='"+banco+"' and anio="+request.getParameter("anio"));  
 	cdo.setAutoIncCol("consecutivo");
	SQLMgr.insert(cdo);
	
  }
  else
  {
  cdo.setWhereClause("cuenta_banco='"+cuenta+"' and banco='"+banco+"' and anio="+request.getParameter("anio")+" and compania="+(String) session.getAttribute("_companyId")+" and consecutivo="+request.getParameter("consecutivo"));
	SQLMgr.update(cdo);
  }
%>
<html>
<head>
<script language="javascript" src="../js/capslock.js"></script>
<script language="javascript">
function closeWindow()
{
<%
if (SQLMgr.getErrCode().equals("1"))
{
%>
	alert('<%=SQLMgr.getErrMsg()%>');
<%
	if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/contabilidad/movimiento_config.jsp"))
	{
%>
	window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/contabilidad/movimiento_config.jsp?mode=edit&cuenta="+cuenta+"&banco="+banco+"&anio="+anio+"&nombre="+nombre)%>';
<%
	}
	else
	{
%>
	window.opener.location = '<%=request.getContextPath()%>/contabilidad/movimiento_config.jsp?mode=edit&cuenta=<%=cuenta%>&banco=<%=banco%>&nombre=<%=nombre%>&anio=<%=anio%>';
<%
	}
%>
	window.close();
<%
} else throw new Exception(SQLMgr.getErrMsg());
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