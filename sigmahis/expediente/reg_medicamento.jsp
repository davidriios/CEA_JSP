<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="cdo" scope="page" class="issi.admin.CommonDataObject" />
<jsp:useBean id="iEsp" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="vEsp" scope="session" class="java.util.Vector" />
<%

SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al, alEsp = new ArrayList();

String sql = "";
String mode = request.getParameter("mode");
String change = request.getParameter("change");
String code = request.getParameter("code");
String id = request.getParameter("id");
String key = "";
String tab = request.getParameter("tab");

boolean noDataFound = false;
boolean viewMode = false;

int espLastLineNo = 0;

if (tab == null) tab = "0";
if (request.getParameter("espLastLineNo") != null) espLastLineNo = Integer.parseInt(request.getParameter("espLastLineNo"));
if (mode == null) mode = "add";
if (mode.equalsIgnoreCase("view"))viewMode = true; 

if (request.getMethod().equalsIgnoreCase("GET"))
{
	if (mode.equalsIgnoreCase("add"))
	{
		code = "0";
		cdo.addColValue("codigo",code);
		iEsp.clear();
		vEsp.clear();
	}
	else
	{
		if (code == null) throw new Exception("El Código del medicamento no es válido. Por favor intente nuevamente!");

		sql = "select codigo, medicamento, accion, interaccion, mensaje, antibio_ctrl, status FROM tbl_sal_medicamentos WHERE codigo ="+code;
		cdo = SQLMgr.getData(sql);
		
		if (cdo == null ){ 
		     cdo = new CommonDataObject();
			 noDataFound = true;
	    }
		
		if (change == null){
		
			iEsp.clear();
			vEsp.clear();
			
		    sql = "select esp.codigo especialidad, esp.descripcion especialidadDesc, esp_med.cod_medicamento from tbl_adm_especialidad_medica esp, tbl_sal_esp_medicamento esp_med where esp.codigo = esp_med.cod_especialidad and esp_med.cod_medicamento = "+code+" order by 2";
			alEsp = SQLMgr.getDataList(sql);
			
			espLastLineNo = alEsp.size();
			
			for (int i=1; i<=alEsp.size(); i++)
			{
				CommonDataObject cdoEsp = (CommonDataObject) alEsp.get(i-1);

				if (i < 10) key = "00" + i;
				else if (i < 100) key = "0" + i;
				else key = "" + i;
				cdoEsp.addColValue("key",key);

				try
				{
					iEsp.put(key, cdoEsp);
					vEsp.addElement(cdoEsp.getColValue("especialidad"));
				}
				catch(Exception e)
				{
					System.err.println(e.getMessage());
				}
			}
			
		}//change is null
	}//else

%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<%@ include file="../common/tab.jsp" %>
<script language="javascript">
document.title = 'Medicamentos Edición - '+document.title;
<%if(mode.equalsIgnoreCase("add")){%>
document.title=" Medicamentos Agregar - "+document.title;
<%}else if(mode.equalsIgnoreCase("edit")){%>
document.title=" Medicamentos Edición - "+document.title;
<%}%>
function showEspecialidadList()
{
	abrir_ventana1('../common/check_especialidad_med.jsp?fp=medicamento&mode=<%=mode%>&code=<%=code%>&espLastLineNo=<%=espLastLineNo%>');
}
function doAction(){
	<% if (request.getParameter("type") != null){
		if (tab.equals("1")){%>
		   showEspecialidadList();
		<%}%>
	<%}%>
}

function medList() {
	abrir_ventana1('../common/search_articulo.jsp?fp=alertas_restringidos&id=12');
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="MEDICAMENTOS- MANTENIMIENTO"></jsp:param>
</jsp:include>

<table align="center" width="99%" cellpadding="0" cellspacing="0">
<tr>
	<td class="TableBorder">

<!-- MAIN DIV START HERE -->
<div id="dhtmlgoodies_tabView1">

<!-- TAB0 DIV START HERE-->
<div class="dhtmlgoodies_aTab">
<table align="center" width="99%" cellpadding="0" cellspacing="0">
	<tr>
		<td width="99%" class="TableBorder">

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->

            <table align="center" width="99%" cellpadding="0" cellspacing="1">
			<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
			<%=fb.formStart(true)%>
			<%=fb.hidden("tab","0")%>
			<%=fb.hidden("mode",mode)%>
			<%=fb.hidden("baction","")%>
			<%=fb.hidden("codigo",cdo.getColValue("codigo"))%>
			<%=fb.hidden("code",code)%>
			<%=fb.hidden("index",request.getParameter("index"))%>
			<%=fb.hidden("espSize",""+iEsp.size())%>
			<%=fb.hidden("espLastLineNo",""+espLastLineNo)%>
				<tr>
					<td colspan="4">&nbsp;</td>
				</tr>
				<tr class="TextRow02">
					<td colspan="4">&nbsp;</td>
				</tr>
				<tr class="TextRow01">
					<td>C&oacute;digo</td>
					<td colspan="3"><%=(cdo.getColValue("codigo")==null?"0":cdo.getColValue("codigo"))%></td>
				</tr>
				<tr class="TextRow01">
						<td>Medicamento</td>
						<td colspan="3"><%=fb.textBox("medicamento",cdo.getColValue("medicamento"),true,false,true,100,500)%>
						
						<%=fb.button("btnMedicamentos","...",true,false,null,null,"onClick=\"javascript:medList()\"","seleccionar medicamento")%>
						<%=fb.hidden("medCode", "")%>

						</td>
				</tr>
				<tr class="TextRow01">
						<td>Acci&oacute;n</td>
						<td><%=fb.textarea("accion",cdo.getColValue("accion"),true,false,false,45,4,300)%></td>
						<td>Interacci&oacute;n</td>
						<td><%=fb.textarea("interaccion",cdo.getColValue("interaccion"),true,false,false,45,4,300)%></td>
				</tr>
				<tr class="TextRow01">
						<td>Mensaje</td>
						<td><%=fb.textarea("mensaje",cdo.getColValue("mensaje"),false,false,false,45,4,300)%><br><span style="color:red;">Si no es necesario que CellByte alerte al m&eacute;dico, dejar en blanco!</span>
						</td>
						<td colspan="2">
						   <table width="100%">
						     <tr>
							    <td width="15%">Tipo</td>
								<td width="20%"><%=fb.select("tipoMed","S=Antibi&oacute;tico Restringido,N=No Restringido",(cdo.getColValue("antibio_ctrl")==null?"N":cdo.getColValue("antibio_ctrl")),false,false,0,null,null,"")%></td>
								<td width="20%" align="center">Estado</td>
								<td width="45%"><%=fb.select("status","A=Activo,I=Inactivo",(cdo.getColValue("status")==null?"A":cdo.getColValue("status")))%></td>
							 </tr>
						   </table>
						</td>
				</tr>
				<tr class="TextRow02">
						<td colspan="6" align="right">
						Opciones de Guardar:
						<%=fb.radio("saveOption","N",false,viewMode,false)%>Crear Otro 
						<%=fb.radio("saveOption","O",true,viewMode,false)%>Mantener Abierto 
						<%=fb.radio("saveOption","C",false,viewMode,false)%>Cerrar 
						<%=fb.submit("save","Guardar",true,noDataFound)%>
						<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
						</td>
				</tr>
            <%=fb.formEnd(true)%>
            </table>

<!-- ================================   F O R M   E N D   H E R E   ================================ -->

		</td>
	</tr>
</table>

<!-- TAB0 DIV ENDS HERE-->
</div>


<!-- TAB1 DIV START HERE-->
<div class="dhtmlgoodies_aTab">
<table align="center" width="99%" cellpadding="0" cellspacing="0">
	<tr>
		<td width="99%" class="TableBorder">

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->

            <table align="center" width="99%" cellpadding="0" cellspacing="1">
			<%fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
			<%=fb.formStart(true)%>
			<%=fb.hidden("tab","1")%>
			<%=fb.hidden("mode",mode)%>
			<%=fb.hidden("baction","")%>
			<%=fb.hidden("codigo",cdo.getColValue("codigo"))%>
			<%=fb.hidden("code",code)%>
			<%=fb.hidden("index",request.getParameter("index"))%>
			<%=fb.hidden("espSize",""+iEsp.size())%>
			<%=fb.hidden("espLastLineNo",""+espLastLineNo)%>
				 <tr class="TextHeader">
					<td colspan="6">
						<table width="100%" cellpadding="1" cellspacing="1">
							<tr class="TextHeader" align="center">
								<td width="10%">C&oacute;digo</td>
								<td width="70%">Nombre de la Especialidad</td>
								<td width="15%">&nbsp;</td>
								<td width="5%"><%=fb.submit("addEspecialidad","+",true,((cdo.getColValue("antibio_ctrl") != null && cdo.getColValue("antibio_ctrl").equalsIgnoreCase("S"))?false:true),null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"","Agregar Especialidades")%></td>
							</tr>
				<%
				alEsp = CmnMgr.reverseRecords(iEsp);
				//System.out.println("theBra!n :::::::::::::::::::::="+vEsp.size());
				for (int i=1; i<=iEsp.size(); i++){
					key = alEsp.get(i - 1).toString();
					CommonDataObject cdoEsp = (CommonDataObject) iEsp.get(key);
				%>
					<%=fb.hidden("key"+i,cdoEsp.getColValue("key"))%>
					<%=fb.hidden("codigoEspec"+i,cdoEsp.getColValue("especialidad"))%>
					<%=fb.hidden("codigoMed"+i,cdoEsp.getColValue("cod_medicamento"))%>
					<%=fb.hidden("especialidadDesc"+i,cdoEsp.getColValue("especialidadDesc"))%>
					<%=fb.hidden("remove"+i,"")%>
					<tr class="TextRow01">
						<td><%=cdoEsp.getColValue("especialidad")%></td>
						<td colspan="2"><%=cdoEsp.getColValue("especialidadDesc")%></td>
						<td align="center"><%=fb.submit("rem"+i,"X",true,false,null,null,"onClick=\"javascript:removeItem('"+fb.getFormName()+"',"+i+")\"","Eliminar Especialidad")%></td>
					</tr>		
					
				<%		
	            }//for
				%>
				</table>
				    </td>		
				</tr>	
				<%
				System.out.println("::::::::::::::::::::::::::::::::"+cdo.getColValue("antibio_ctrl"));
				%>
                    <tr class="TextRow02">
						<td colspan="6" align="right">
						Opciones de Guardar:
						<%=fb.radio("saveOption","N",false,viewMode,false)%>Crear Otro 
						<%=fb.radio("saveOption","O",true,viewMode,false)%>Mantener Abierto 
						<%=fb.radio("saveOption","C",false,viewMode,false)%>Cerrar 
						<%=fb.submit("save","Guardar",true,((cdo.getColValue("antibio_ctrl") != null && cdo.getColValue("antibio_ctrl").equalsIgnoreCase("S"))?false:true))%>
						<%=fb.button("cancel","Cancelar",false,false,null,null,"onclick=\"window.close();\"")%></td>
				    </tr>
				<tr>
					<td colspan="2">&nbsp;</td>
				</tr>
            <%=fb.formEnd(true)%>
            </table>

<!-- ================================   F O R M   E N D   H E R E   ================================ -->

		</td>
	</tr>
</table>

<!-- TAB1 DIV ENDS HERE-->
</div>

<!-- MAIN DIV ENDS HERE -->
</div>

<script type="text/javascript">
<%
if (mode.equalsIgnoreCase("add"))
{
%>
initTabs('dhtmlgoodies_tabView1',Array('Medicamentos'),0,'100%','');
<%
}
else
{
%>
initTabs('dhtmlgoodies_tabView1',Array('Medicamentos','Especialidades'),<%=tab%>,'100%','');
<%
}
%>
</script>
</td></tr></table>

<%@ include file="../common/footer.jsp"%>
</body>
</html>
<%
}//GET
else
{
  String saveOption = request.getParameter("saveOption");//N=Create New,O=Keep Open,C=Close
  String baction = request.getParameter("baction");
  
  //MEDICAMENTOS
  if (tab.equals("0")) {
		  cdo = new CommonDataObject();
		  
		  cdo.setTableName("tbl_sal_medicamentos");
		  cdo.addColValue("medicamento",request.getParameter("medicamento"));
		  cdo.addColValue("accion",request.getParameter("accion"));
		  cdo.addColValue("interaccion",request.getParameter("interaccion"));
		  cdo.addColValue("compania",(String)session.getAttribute("_companyId"));
		  cdo.addColValue("mensaje",request.getParameter("mensaje"));
		  cdo.addColValue("antibio_ctrl",request.getParameter("tipoMed"));
		  cdo.addColValue("status",request.getParameter("status"));

		  if (mode.equalsIgnoreCase("add"))
		  {
			cdo.setAutoIncCol("codigo");
			cdo.addPkColValue("codigo","");
			SQLMgr.insert(cdo);
			code = SQLMgr.getPkColValue("codigo");
		  }
		  else
		  {
			cdo.setWhereClause("codigo="+request.getParameter("codigo"));
			SQLMgr.update(cdo);
	      }  
   }
   else if (tab.equals("1")){
	   int size = 0;
		if (request.getParameter("espSize") != null) size = Integer.parseInt(request.getParameter("espSize"));
		String itemRemoved = "";
		alEsp.clear();
				
		for (int i=1; i<=size; i++){
		   cdo = new CommonDataObject();
		   cdo.setTableName("tbl_sal_esp_medicamento");
		   cdo.setWhereClause("cod_medicamento ='"+code+"'");
		   cdo.addColValue("key",request.getParameter("key"+i));
		   cdo.addColValue("especialidad",request.getParameter("codigoEspec"+i));
		   cdo.addColValue("cod_medicamento",code);
		   cdo.addColValue("especialidadDesc",request.getParameter("especialidadDesc"+i));
		   cdo.addColValue("cod_especialidad",request.getParameter("codigoEspec"+i));
		   
		   if (request.getParameter("remove"+i) != null && !request.getParameter("remove"+i).equals("")){
				itemRemoved = cdo.getColValue("key");
			}
			else
			{
				try
				{
					iEsp.put(cdo.getColValue("key"),cdo);
					alEsp.add(cdo);
				}
				catch(Exception e)
				{
					System.err.println(e.getMessage());
				}
			}
		   
		}//for i
				
		if (!itemRemoved.equals(""))
		{
			vEsp.remove(((CommonDataObject) iEsp.get(itemRemoved)).getColValue("especialidad"));
			iEsp.remove(itemRemoved);

			response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&tab=1&mode="+mode+"&code="+code+"&espLastLineNo="+espLastLineNo);
			return;
		}
		
		if (baction != null && baction.equals("+"))
		{
			response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&tab=1&type=1&mode="+mode+"&code="+code+"&espLastLineNo="+espLastLineNo);
			return;
		}

		if (alEsp.size() == 0)
		{
			cdo = new CommonDataObject();
			cdo.setTableName("tbl_sal_esp_medicamento");
		    cdo.setWhereClause("cod_medicamento ='"+code+"'");
			alEsp.add(cdo);
		}

		ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
		SQLMgr.insertList(alEsp);
		ConMgr.clearAppCtx(null);
		
		
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
	if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/expediente/list_medicamentos.jsp"))
	{
%>
	window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/expediente/list_medicamentos.jsp")+"?index="+request.getParameter("index")%>';
<%
	}
	else
	{
%>
	window.opener.location = '<%=request.getContextPath()%>/expediente/list_medicamentos.jsp?index=<%=request.getParameter("index")%>';
<%
	}
	
if (saveOption.equalsIgnoreCase("N")){
%>
	setTimeout('addMode()',500);
<%
	}else if (saveOption.equalsIgnoreCase("O")){
%>
	setTimeout('editMode()',500);
<%
	}else if (saveOption.equalsIgnoreCase("C")){
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
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?mode=edit&code=<%=code%>&tab=<%=tab%>';
}
</script>			
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>