<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Hashtable"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>

<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="iLic" scope="session" class="java.util.Hashtable" />
<%
/**
==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);
CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
CommonDataObject cdo = new CommonDataObject();

boolean viewMode = false;
String mode = request.getParameter("mode");
String codigo = request.getParameter("codigo");
String empId = request.getParameter("empId");
String fg = request.getParameter("fg");
String fechaDesde = request.getParameter("fechaDesde");
String fechaHasta = request.getParameter("fechaHasta");
String quincenas = request.getParameter("quincenas");
String provincia = request.getParameter("provincia");
String sigla = request.getParameter("sigla");
String tomo = request.getParameter("tomo");
String asiento = request.getParameter("asiento");

int iconHeight = 50;
int iconWidth = 50;

if (fg == null) fg = "";
if (mode == null) mode = "add";
if (mode.equalsIgnoreCase("view")) viewMode = true;

String sql2 = "";
StringBuffer sbSql = new StringBuffer();
String change = request.getParameter("change");
String key = "";
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
if (request.getMethod().equalsIgnoreCase("GET"))
{

	iLic.clear();
	if(mode.trim().equals("add")&& fg.trim().equals("DIST"))
	{
		/*sbSql = new StringBuffer();
		sbSql.append("call sp_pla_distribuir_salario(");
		sbSql.append(pacId);
		sbSql.append(",");
		sbSql.append(noAdmision);
		sbSql.append(",'");
		sbSql.append(esJubilado);
		sbSql.append("',");
		sbSql.append(session.getAttribute("_companyId"));
		sbSql.append(")");
		SQLMgr.execute(sbSql.toString());
		if (!SQLMgr.getErrCode().equals("1")) throw new Exception (SQLMgr.getErrException());*/
		
		
	}
	else
	{
		sbSql = new StringBuffer();
		
		sbSql.append("select  t.compania, t.provincia, t.sigla,t.tomo, t.asiento, t.codigo,t.anio, t.periodo, to_char(t.pfecha_inicio,'dd/mm/yyyy')pfecha_inicio,to_char(t.pfecha_final,'dd/mm/yyyy')pfecha_final, t.sal_bruto, t.seg_social, t.seg_educativo, t.imp_renta, t.num_cheque, t.fecha_cheque, t.explicacion, t.usuario_creacion, to_char(t.fecha_creacion,'dd/mm/yyyy hh12:mi:ss am')fecha_creacion, t.usuario_modificacion, t.fecha_modificacion, t.acum_decimo, t.emp_id,t.desc_mes,t.estado from tbl_pla_pago_licencia t where compania= ");
		sbSql.append(session.getAttribute("_companyId"));
		sbSql.append(" and emp_id = ");
		sbSql.append(empId);
		sbSql.append(" and codigo =");
		sbSql.append(codigo);
		sbSql.append(" order by t.anio,t.periodo asc ");
	
		al=SQLMgr.getDataList(sbSql.toString());
		
		for(int h=0;h<al.size();h++)
		{
			CommonDataObject cdo2 = (CommonDataObject) al.get(h);
			cdo2.setKey(h);
			cdo2.setAction("U");

			iLic.put(cdo2.getKey(),cdo2);
			if(!cdo2.getColValue("estado").trim().equals("P")|| viewMode==true ){
			mode="view";
			viewMode=true;}
			
		}
		if(al.size() !=0)quincenas = ""+al.size();
	}

%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript">
document.title = 'Distribucion de pagos a Licencia - '+document.title;
function distribuir()
{
var salarioPagado = eval('document.form0.salarioPagado').value;
var quincenas = eval('document.form0.quincenas').value;
var provincia = eval('document.empleado.provincia').value;
var sigla = eval('document.empleado.sigla').value;
var tomo = eval('document.empleado.tomo').value;
var asiento = eval('document.empleado.asiento').value;
if(quincenas !='' && quincenas !='0'){
if(salarioPagado !='' && salarioPagado !='0' && salarioPagado !='0.00' && !isNaN(salarioPagado)){
		showPopWin('../common/run_process.jsp?fp=DISTLIC&actType=50&docType=DISTLIC&docId=<%=empId%>&docNo=<%=empId%>&compania=<%=(String) session.getAttribute("_companyId")%>&mode=<%=mode%>&codigo=<%=codigo%>&fechaIni=<%=fechaDesde%>&fechaFin=<%=fechaHasta%>&empId=<%=empId%>&provincia='+provincia+'&sigla='+sigla+'&tomo='+tomo+'&asiento='+asiento+'&monto='+salarioPagado+'&quincena='+quincenas,winWidth*.75,winHeight*.65,null,null,'');

}else alert('Valores invalidos en Salario  pagado... Verifique!!!');
}else{alert('El tiempo registrado para la licencias es menor a un mes, no aplica para este Proceso!');}
}
function eliminarDist()
{
		var salarioPagado = eval('document.form0.salarioPagado').value;
var quincenas = eval('document.form0.quincenas').value;

		showPopWin('../common/run_process.jsp?fp=DISTLIC&actType=52&docType=DISTLIC&docId=<%=empId%>&docNo=<%=empId%>&compania=<%=(String) session.getAttribute("_companyId")%>&mode=<%=mode%>&codigo=<%=codigo%>&fechaIni=<%=fechaDesde%>&fechaFin=<%=fechaHasta%>&empId=<%=empId%>&monto='+salarioPagado+'&quincena='+quincenas,winWidth*.75,winHeight*.65,null,null,'');

}
function doAction()
{
var size1 = parseInt(document.getElementById("licSize").value);
var total =0;
	for (i=0;i<size1;i++){total +=  parseFloat(eval('document.form0.sal_bruto'+i).value);}
	total = total.toFixed(2);
 	document.form0.salarioPagado.value=total;
	if(total !='' && total !='0')setSalario();

}
function setSalario()
{	
var salarioQuincenal= 0.00;
var salarioPagado = eval('document.form0.salarioPagado').value;
var quincenas = eval('document.form0.quincenas').value;

if(salarioPagado !='' && salarioPagado !='0' && !isNaN(salarioPagado)){
if(quincenas !='0') salarioQuincenal= (salarioPagado/quincenas).toFixed(2);
document.form0.salarioQuincenal.value =  salarioQuincenal;
}else alert('Valores invalidos. Verifique!!!');
}
function actDistribuir()
{
	var size = parseInt(document.getElementById("licSize").value);
	var salarioPagado = eval('document.form0.salarioPagado').value;
	var quincenas = eval('document.form0.quincenas').value;

	if(size != 0){	
			showPopWin('../common/run_process.jsp?fp=DISTLIC&actType=51&docType=DISTLIC&docId=<%=empId%>&docNo=<%=empId%>&compania=<%=(String) session.getAttribute("_companyId")%>&mode=<%=mode%>&codigo=<%=codigo%>&fechaIni=<%=fechaDesde%>&fechaFin=<%=fechaHasta%>&empId=<%=empId%>&monto='+salarioPagado+'&quincena='+quincenas,winWidth*.75,winHeight*.65,null,null,'');
			}else alert('No existen registros para actualizar..');

}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="DISTRIBUCION DE PAGOS A LICENCIAS"></jsp:param>
	<jsp:param name="displayCompany" value="n"></jsp:param>
	<jsp:param name="displayLineEffect" value="n"></jsp:param>
	<jsp:param name="useThis" value="y"></jsp:param>
</jsp:include>
<table align="center" width="100%" cellpadding="0" cellspacing="0">
		<tr>
			<td>
			<jsp:include page="../common/empleado.jsp" flush="true">
			<jsp:param name="empId" value="<%=empId%>"></jsp:param>
			<jsp:param name="fp" value="licencia"></jsp:param>
			<jsp:param name="mode" value="<%=mode%>"></jsp:param>
			</jsp:include>
			</td>
		</tr>
	<tr>
		<td>
<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
			<table width="100%" cellpadding="1" cellspacing="1" >
					 <%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
					 <%fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value!='Guardar')return true;");%>
					 <%=fb.formStart(true)%>
					 <%=fb.hidden("baction","")%>
					 <%=fb.hidden("mode",mode)%>
					 <%=fb.hidden("codigo",codigo)%>
					 <%=fb.hidden("empId",empId)%>
					 <%=fb.hidden("licSize",""+iLic.size())%>
					
						<tr class="TextHeader01">
						<td colspan="8">Distribucion de Licencia</td>
						</tr>	
						
						<tr class="TextRow01">
							<td colspan="2">Duraci&oacute;n de la Licencia</td>
							<td align="right">Desde</td>
							<td><%=fb.textBox("fechaDesde",fechaDesde,false,false,true,10)%></td>
							<td align="right">Hasta</td>
							<td><%=fb.textBox("fechaHasta",fechaHasta,false,false,true,10)%></td>
							<td align="right">Cant. Quincenas</td>
							<td align="left"><%=fb.textBox("quincenas",quincenas,false,false,true,15)%></td>
						</tr>
						<tr class="TextRow01">
							<td>Salario Pagado</td>
							<td><%=fb.decBox("salarioPagado","",false,false,viewMode,15,12.2,"","","onChange=\"javascript:setSalario();\"")%></td>
							<td>Monto Quincenal</td>
							<td><%=fb.decBox("salarioQuincenal","",false,false,true,15)%></td>
							<td><%if(!mode.trim().equals("view")){%><img height="<%=iconHeight%>" width="<%=iconWidth%>" src="../images/distribute.gif" style="text-decoration:none; cursor:pointer" onMouseOver="javascript:displayElementValue('lblDesc','Distribuir Pago de Licencia')" onMouseOut="javascript:displayElementValue('lblDesc','')"  onClick="javascript:distribuir()"><%}%>
							<%if(iLic.size()!=0 && !mode.trim().equals("view")){%>
							<img height="<%=iconHeight%>" width="<%=iconWidth%>" src="../images/trash.gif" style="text-decoration:none; cursor:pointer" onMouseOver="javascript:displayElementValue('lblDesc','Eliminar Distribucion de Pago de Licencia')" onMouseOut="javascript:displayElementValue('lblDesc','')"  onClick="javascript:eliminarDist()">
							
							<%}%>
							
							
							</td>
							<td colspan="3" valign="bottom"><%if(iLic.size()!=0 && !mode.trim().equals("view")){%><img height="<%=iconHeight%>" width="<%=iconWidth%>" src="../images/actualizar.gif"  style="text-decoration:none; cursor:pointer" onMouseOver="javascript:displayElementValue('lblDesc','Actualizar Distribucion (Aplica distribucion en Exp De Empleado)')" onMouseOut="javascript:displayElementValue('lblDesc','')"  onClick="javascript:actDistribuir()"><%}%><!--<authtype type='51'></authtype>-->
							<label id="lblDesc" class="RedTextBold"></label>
							</td>
						</tr>
						
						<tr class="TextHeader">
								<td width="10%">Año</td>
								<td width="10%">Mes</td>
								<td width="10%">Periodo</td>
								<td width="10%">Fecha Inicio</td>
								<td width="10%">Fecha Final</td>
								<td width="10%">Salario</td>
								<!--<td width="10%">Sec. Social</td>
								<td width="10%">Sec. Educ.</td>
								<td width="10%">Imp. S/R</td>-->
								<td width="5%">Acum. XIII?</td>
								<td width="5%" align="center">&nbsp;
								<%//=fb.submit("agregar","+",true,viewMode,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"","Agregar")%></td>
						</tr>
					
						<%
						al = CmnMgr.reverseRecords(iLic);
							for (int i=0; i<iLic.size(); i++)
							{
								key = al.get(i).toString();
								CommonDataObject cdos =(CommonDataObject) iLic.get(key);

								String color = "TextRow01";
								if (i % 2 == 0) color = "TextRow02";
						%>
								<%=fb.hidden("remove"+i,"")%>
								<%=fb.hidden("action"+i,cdos.getAction())%>
								<%=fb.hidden("key"+i,cdos.getKey())%>
								<%=fb.hidden("provincia"+i,cdos.getColValue("provincia"))%>
								<%=fb.hidden("sigla"+i,cdos.getColValue("sigla"))%>
								<%=fb.hidden("tomo"+i,cdos.getColValue("tomo"))%>
								<%=fb.hidden("asiento"+i,cdos.getColValue("asiento"))%>
								<%=fb.hidden("num_cheque"+i,cdos.getColValue("num_cheque"))%>
								<%=fb.hidden("fecha_cheque"+i,cdos.getColValue("fecha_cheque"))%>
								<%=fb.hidden("explicacion"+i,cdos.getColValue("explicacion"))%>
								<%=fb.hidden("usuario_creacion"+i,cdos.getColValue("usuario_creacion"))%>
								<%=fb.hidden("usuario_modificacion"+i,cdos.getColValue("usuario_modificacion"))%>
								<%=fb.hidden("fecha_modificacion"+i,cdos.getColValue("fecha_modificacion"))%>
								<%=fb.hidden("fecha_creacion"+i,cdos.getColValue("fecha_creacion"))%>
								<%=fb.hidden("estado"+i,cdos.getColValue("estado"))%>
								
								
					<tr class="<%=color%>">
						<td><%=fb.textBox("anio"+i,cdos.getColValue("anio"),false,false,true,10)%></td>
						<td><%=fb.textBox("desc_mes"+i,cdos.getColValue("desc_mes"),false,false,true,10)%></td>
						<td><%=fb.textBox("periodo"+i,cdos.getColValue("periodo"),false,false,true,10)%></td>
						<td><%=fb.textBox("pfecha_inicio"+i,cdos.getColValue("pfecha_inicio"),false,false,true,10)%></td> 
						<td><%=fb.textBox("pfecha_final"+i,cdos.getColValue("pfecha_final"),false,false,true,10)%></td> 
						<td><%=fb.decBox("sal_bruto"+i,cdos.getColValue("sal_bruto"),false,false,true,15,12.2)%></td> 
						<!--<td><%=fb.decBox("seg_social"+i,cdos.getColValue("seg_social"),false,false,true,15,12.2)%></td> 
						<td><%=fb.decBox("seg_educativo"+i,cdos.getColValue("seg_educativo"),false,false,true,15,12.2)%></td> 
						<td><%=fb.decBox("imp_renta"+i,cdos.getColValue("imp_renta"),false,false,true,15,12.2)%></td> -->
						<td><%=fb.checkbox("acum_decimo"+i,"",(cdos.getColValue("acum_decimo").trim().equals("S")),true,null,null,"")%></td>
						<td align="center">&nbsp;
						<%//=fb.submit("rem"+i,"X",false,viewMode,null,null,"onClick=\"javascript:removeItem('"+fb.getFormName()+"',"+i+")\"","Eliminar")%></td>
					</tr>
    <%
	  }
	fb.appendJsValidation("if(error>0)doAction();");
	%>
								</table>
								</td>
						</tr>
						<tr class="TextRow02" align="right">
								<td colspan="4">
				<!--Opciones de Guardar:-->
				<!--<%=fb.radio("saveOption","N",false,viewMode,false)%>Crear Otro-->
				<!--<%=fb.radio("saveOption","O",true,viewMode,false)%>Mantener Abierto
				<%=fb.radio("saveOption","C",false,viewMode,false)%>Cerrar-->
				<%//=fb.submit("save","Guardar",true,viewMode,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%>
				<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%></td>
						</tr>
						<%=fb.formEnd(true)%>
			</table>
		</td>
	</tr>
</table>
</body>
</html>
<%
}//fin GET
else if(request.getMethod().equalsIgnoreCase("POST"))
{

String saveOption = request.getParameter("saveOption");//N=Create New,O=Keep Open,C=Close
String baction = request.getParameter("baction");

ArrayList list= new ArrayList();
int keySize=Integer.parseInt(request.getParameter("licSize"));
String itemRemoved="";
		
iLic.clear();
for(int a=0; a<keySize; a++)
{ 

  CommonDataObject cdo1 = new CommonDataObject();

  cdo1.setTableName("tbl_pla_pago_licencia");  
  cdo1.setWhereClause("compania="+(String) session.getAttribute("_companyId")+" and emp_id="+empId+" and codigo="+codigo+" and estado='P' and anio ="+request.getParameter("anio"+a)+" and periodo ="+request.getParameter("periodo"+a));
  cdo1.addColValue("emp_id",empId);
  /*cdo1.addColValue("provincia",request.getParameter("provincia"+a)); 
  cdo1.addColValue("sigla",request.getParameter("sigla"+a));
  cdo1.addColValue("tomo",request.getParameter("tomo"+a));
  cdo1.addColValue("asiento",request.getParameter("asiento"+a));   
  cdo1.addColValue("compania",(String) session.getAttribute("_companyId"));
  cdo1.addColValue("codigo",codigo);
  cdo1.addColValue("anio",request.getParameter("anio"+a));
  cdo1.addColValue("periodo",request.getParameter("periodo"+a));*/
  cdo1.addColValue("pfecha_inicio",request.getParameter("pfecha_inicio"+a));
  cdo1.addColValue("pfecha_final",request.getParameter("pfecha_final"+a));
  cdo1.addColValue("sal_bruto",request.getParameter("sal_bruto"+a).replaceAll(",",""));  
  cdo1.addColValue("seg_social",request.getParameter("seg_social"+a).replaceAll(",",""));  
  cdo1.addColValue("seg_educativo",request.getParameter("seg_educativo"+a).replaceAll(",",""));  
  cdo1.addColValue("imp_renta",request.getParameter("imp_renta"+a).replaceAll(",",""));  
  cdo1.addColValue("num_cheque",request.getParameter("num_cheque"+a));  
  cdo1.addColValue("fecha_cheque",request.getParameter("fecha_cheque"+a));  
  cdo1.addColValue("explicacion",request.getParameter("explicacion"+a));  
  cdo1.addColValue("usuario_creacion",request.getParameter("usuario_creacion"+a));  
  cdo1.addColValue("fecha_creacion",request.getParameter("fecha_creacion"+a));  
  cdo1.addColValue("usuario_modificacion",(String) session.getAttribute("_userName"));
  cdo1.addColValue("fecha_modificacion",cDateTime);  

  if (request.getParameter("acum_decimo"+a) != null)
  cdo1.addColValue("acum_decimo","S");  
  else cdo1.addColValue("acum_decimo","N");  
  cdo1.setKey(a);
  cdo1.setAction(request.getParameter("action"+a));
  cdo1.addColValue("estado",request.getParameter("estado"+a));  
  cdo1.addColValue("desc_mes",request.getParameter("desc_mes"+a));

    if (request.getParameter("remove"+a) != null && !request.getParameter("remove"+a).equals(""))
	{
		//itemRemoved = cdo1.getColValue("num_descuento")+"-"+cdo1.getColValue("secuencia");
		if (cdo1.getAction().equalsIgnoreCase("I")) cdo1.setAction("X");//if it is not in DB then remove it
		else cdo1.setAction("D");
	}
	
	if (!cdo1.getAction().equalsIgnoreCase("X"))
	{
		try
		{
			iLic.put(cdo1.getKey(),cdo1);
			//vDesc.add(cdo1.getColValue("cod_acreedor")+"-"+cdo1.getColValue("cod_grupo"));
			list.add(cdo1);
		}
		catch(Exception e)
		{
			System.err.println(e.getMessage());
		}
	}
	
 }//End For
 
	if(!itemRemoved.equals(""))
	{
	//iDesc.remove(itemRemoved);
	response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&empId="+empId+"&codigo="+codigo+"&mode="+mode+"&fg="+fg+"&fechaHasta="+fechaHasta+"&fechaDesde="+fechaDesde+"&provincia="+provincia+"&sigla="+sigla+"&tomo="+tomo+"&asiento="+asiento);
	return;
	}

if(request.getParameter("btnagregar")!=null)
{
	CommonDataObject cdo1 = new CommonDataObject();
	cdo1.addColValue("periodo","");
	cdo1.addColValue("fecha_creacion",cDateTime);
	cdo1.addColValue("usuario_creacion",(String) session.getAttribute("_userName"));
	cdo1.setAction("I");
	cdo1.setKey(iLic.size() + 1);
	
	iLic.put(key,cdo1);
	response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&empId="+empId+"&codigo="+codigo+"&mode="+mode+"&fg="+fg+"&fechaHasta="+fechaHasta+"&fechaDesde="+fechaDesde+"&provincia="+provincia+"&sigla="+sigla+"&tomo="+tomo+"&asiento="+asiento);
	 return;

}
if(list.size()==0){
CommonDataObject cdo1 = new CommonDataObject();
cdo1.setTableName("tbl_pla_pago_licencia");  
cdo1.setWhereClause("compania="+(String) session.getAttribute("_companyId")+" and emp_id="+empId+" and codigo=-1");
cdo1.setKey(iLic.size() + 1);
cdo1.setAction("I");
list.add(cdo1);
} 
ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
 SQLMgr.saveList(list,true);
ConMgr.clearAppCtx(null);
	
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
	
	//if (tab.equals("0"))
	//{
		if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/rhplanilla/descuento_ajuste.jsp"))
		{
%>
	//window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/rhplanilla/descuento_list.jsp")%>';
<%
		}
		else
		{
%>
	  //window.opener.location = '<%=request.getContextPath()%>/rhplanilla/list_licencia_view.jsp?emp_id=<%=empId%>&mode=view';
<%
		}
		
	//}

	if (saveOption.equalsIgnoreCase("N"))
	{
%>
	setTimeout('addMode()',500);
<%
	}
	else if (saveOption.equalsIgnoreCase("O"))
	{
%>
	setTimeout('editMode()',500);
<%
	}
	else if (saveOption.equalsIgnoreCase("C"))
	{
%>
	window.close();
<%
	}
} else throw new Exception(SQLMgr.getErrMsg());
%>
}

function addMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>';
}

function editMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?mode=<%=mode%>&codigo=<%=codigo%>&fechaDesde=<%=fechaDesde%>&fechaHasta=<%=fechaHasta%>&empId=<%=empId%>&fg=<%=fg%>&provincia=<%=provincia%>&sigla=<%=sigla%>&tomo=<%=tomo%>&asiento=<%=asiento%>&quincenas=<%=quincenas%>';
}

</script>

</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>
