<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" 	%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="iCds" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="vCds" scope="session" class="java.util.Vector" />

<%
/**
==================================================================================
==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
//if (SecMgr.checkAccess(session.getId(),"0")) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

CommonDataObject cdo1 = new CommonDataObject();

ArrayList al = new ArrayList();
String key = "";
String sql = "";
String mode = request.getParameter("mode");
String id = request.getParameter("id");
String tab = request.getParameter("tab");
String change = request.getParameter("change");
int cdsLastLineNo =0;
boolean viewMode = false;

if (mode == null) mode = "add";
if (mode.equalsIgnoreCase("view")) viewMode = true;
if (tab == null) tab = "0";
if (request.getParameter("cdsLastLineNo") != null) cdsLastLineNo = Integer.parseInt(request.getParameter("cdsLastLineNo"));
if (request.getMethod().equalsIgnoreCase("GET"))
{
	if (mode.equalsIgnoreCase("add"))
	{   
		id = "0";
		iCds.clear();
		vCds.clear();
	}
	else
	{
		if (id == null) throw new Exception("El Codigo de la guia no es válido. Por favor intente nuevamente!");

		sql = "select id, nombre, descripcion,tipo, status from tbl_sal_guia  where id = "+id;
		cdo1 = SQLMgr.getData(sql);
		if(change ==null)
		{
			 iCds.clear();
		     vCds.clear();
			
			 sql="select  a.cod_guia,a.codigo,a.cds,b.descripcion,a.cds,a.estado from tbl_sal_guia_cds a, tbl_cds_centro_servicio b where a.cds =b.codigo and a.cod_guia = "+id+"  order by a.codigo desc";
al = SQLMgr.getDataList(sql);
cdsLastLineNo = al.size();
      for (int i=0; i<al.size(); i++)
      {
       CommonDataObject cdo = (CommonDataObject) al.get(i);

        if (i < 10) key = "00" + i;
        else if (i < 100) key = "0" + i;
        else key = "" + i;
        cdo.addColValue("key",key);

        try
        {
          iCds.put(key, cdo);
          vCds.addElement(cdo.getColValue("cds"));
        }
        catch(Exception e)
        {
          System.err.println(e.getMessage());
        }
      }

		}

	}
%>
<html>   
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<%@ include file="../common/tab.jsp" %>
<script language="javascript">
<%if (mode.equalsIgnoreCase("add")){%>
document.title="Guias de Cuidados - Agregar - "+document.title;
<%}else if (mode.equalsIgnoreCase("edit")){%>
document.title="Guia de Cuidados - Edición - "+document.title;
<%}%>
function doAction(){
setHeight();
	<%if(request.getParameter("type")!=null && request.getParameter("type").trim().equals("1")){%>
	cdsList();
	<%}%>
}	
function cdsList()
{
	abrir_ventana1('../common/check_cds.jsp?fp=guia&mode=<%=mode%>&id=<%=id%>&cdsLastLineNo=<%=cdsLastLineNo%>');
}
function setHeight()
{
	newHeight();
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="EXPEDIENTE - MANTENIMIENTO"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
<tr>
	<td class="TableBorder">
		<table align="center" width="100%" cellpadding="5" cellspacing="0">
		<tr>
			<td>

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
<!-- MAIN DIV START HERE -->
<div id="dhtmlgoodies_tabView1">

<!-- TAB0 DIV START HERE-->
<div class="dhtmlgoodies_aTab">
<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
			<table width="100%" cellpadding="1" cellspacing="1" >

<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("id",id)%>
<%=fb.hidden("errCode","")%>
<%=fb.hidden("errMsg","")%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("tab","0")%>
<%=fb.hidden("size",""+iCds.size())%>
<%=fb.hidden("cdsLastLineNo",""+cdsLastLineNo)%>


				<tr class="TextRow02">
					<td>&nbsp;</td>
				</tr>
				<tr>
					<td onClick="javascript:showHide(0)" style="text-decoration:none; cursor:pointer">
						<table width="100%" cellpadding="1" cellspacing="0">
						<tr class="TextPanel">
							<td width="95%">&nbsp;<cellbytelabel id="1">Instrucciones y Cuidados</cellbytelabel></td>
							<td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus0" style="display:none">+</label><label id="minus0">-</label></font>]&nbsp;</td>
						</tr>
						</table>
					</td>
				</tr>
				<tr id="panel0">
					<td>	
						<table width="100%" cellpadding="1" cellspacing="1">									
							<tr class="TextRow01">
								<td width="10%"><cellbytelabel id="2">C&oacute;digo</cellbytelabel></td>
							    <td width="35%"><%=fb.intBox("codigo",id,false,false,true,10,3)%></td>														
								<td width="15%"><cellbytelabel id="3">Nombre</cellbytelabel></td>
							    <td width="40%"><%=fb.textBox("nombre",cdo1.getColValue("nombre"),true,false,false,50,100)%></td>	
							</tr>	
							<tr class="TextRow01">
								<td><cellbytelabel id="4">Descripci&oacute;n</cellbytelabel></td>
							    <td><%=fb.textBox("descripcion",cdo1.getColValue("descripcion"),false,false,false,50,100)%></td>	
								<td><cellbytelabel id="5">Tipo</cellbytelabel></td>
								<td><%=fb.select("tipo","C=CUIDADOS,PA=PLAN DE ACCION",cdo1.getColValue("tipo"),false,viewMode,0,"Text10",null,null,"","")%></td>																					
							</tr>
							<tr class="TextRow01">
								
							    <td><cellbytelabel id="6">Estado</cellbytelabel></td>
								<td colspan="3"><%=fb.select("status","A=ACTIVO,I=INACTIVO",cdo1.getColValue("status"),false,viewMode,0,"Text10",null,null,"","")%></td>																						
							</tr>														
						</table>
					</td>
				</tr>
				
				
				<tr class="TextRow02">
					<td align="right">
						Opciones de Guardar: 
						<%=fb.radio("saveOption","N")%>Crear Otro 
						<%=fb.radio("saveOption","O")%>Mantener Abierto 
						<%=fb.radio("saveOption","C",true,false,false)%>Cerrar 
						<%=fb.submit("save","Guardar",true,viewMode)%>
						<%=fb.button("cancel","Cancelar",false,false,null,null,"onClick=\"javascript:window.close()\"")%>
					</td>
				</tr>
<%=fb.formEnd(true)%>

<!-- ================================   F O R M   E N D   H E R E   ================================ -->

				</table>
<!-- TAB0 DIV END HERE-->
</div>
<!-- TAB1 DIV START HERE-->
<div class="dhtmlgoodies_aTab">
<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
			<table width="100%" cellpadding="1" cellspacing="1" >
					 <%fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
					 <%fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value!='Guardar')return true;");%>
					 <%=fb.formStart(true)%>
					 <%=fb.hidden("baction","")%>
					 <%=fb.hidden("mode",mode)%>
					 <%=fb.hidden("tab","1")%>
					 <%=fb.hidden("id",""+id)%>
					 <%=fb.hidden("size",""+iCds.size())%>
					 <%=fb.hidden("cdsLastLineNo",""+cdsLastLineNo)%>

						<tr class="TextHeader">
								<td width="15%">Centro Servicio</td>
								<td width="65%"><cellbytelabel id="4">Descripci&oacute;n</cellbytelabel></td>
								<td width="15%"><cellbytelabel id="6">Estado</cellbytelabel></td>
								<td width="05%" align="center"><%=fb.submit("addCds","+",false,viewMode,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"","Agregar Centro")%></td>

					</tr>

					<%
						al = CmnMgr.reverseRecords(iCds);
for (int i=0; i<iCds.size(); i++)
{
  key = al.get(i).toString();
  CommonDataObject cdo = (CommonDataObject) iCds.get(key);
  String displayCds="";
  if (cdo.getColValue("status") != null && cdo.getColValue("status").trim().equalsIgnoreCase("D")) displayCds = " style=\"display:none\"";
%>
				 		<%=fb.hidden("key"+i,key)%>
            			<%=fb.hidden("remove"+i,"")%>
						<%=fb.hidden("status"+i,""+cdo.getColValue("status"))%>
						<tr class="TextRow01"<%=displayCds%>>
						<td><%=fb.textBox("cds"+i,cdo.getColValue("cds"),(!displayCds.trim().equals(""))?false:true,false,false,10,"Text10","","")%></td>
						<td><%=fb.textBox("descripcion"+i,cdo.getColValue("descripcion"),false,false,true,70,"Text10","","")%></td>
						<td><%=fb.select("estado"+i,"A=ACTIVO,I=INACTIVO",cdo.getColValue("estado"),false,viewMode,0,"Text10",null,null,"","")%></td>
						<td align="center"><%//=fb.submit("rem"+i,"X",true,viewMode,null,null,"onClick=\"javascript:removeItem('"+fb.getFormName()+"',"+i+")\"","Eliminar Centro.")%></td>
						</tr>

 <%	}
		fb.appendJsValidation("if(error>0)setHeight();");
	%>

						<tr class="TextRow02" align="right">
								<td colspan="4">
      	<cellbytelabel id="7">Opciones de Guardar</cellbytelabel>:
        <!--<%=fb.radio("saveOption","N",false,viewMode,false)%>Crear Otro-->
        <%=fb.radio("saveOption","O",true,viewMode,false)%><cellbytelabel id="8">Mantener Abierto</cellbytelabel>
        <%=fb.radio("saveOption","C",false,viewMode,false)%><cellbytelabel id="9">Cerrar</cellbytelabel>
        <%=fb.submit("save","Guardar",true,viewMode,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%>
				<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
								</td>
						</tr>
						<%=fb.formEnd(true)%>
			</table>
<!-- TAB1 DIV END HERE-->
</div>
<!-- TAB2 DIV START HERE-->
</div>
	
<script type="text/javascript">
<%
String tabLabel = "'Datos Generales'";
if (!mode.equalsIgnoreCase("add")){
   tabLabel += ",'Centros Servicio'";
}
%>
initTabs('dhtmlgoodies_tabView1',Array(<%=tabLabel%>),<%=tab%>,'100%','');
</script>			
				
			</td>
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
	String saveOption = request.getParameter("saveOption"); //N=Create New,O=Keep Open,C=Close
	String baction = request.getParameter("baction");
 
 if (tab.equals("0")) //Protocolo
 {
	  cdo1 = new CommonDataObject();
	  cdo1.setTableName("tbl_sal_guia");
	  cdo1.addColValue("descripcion",request.getParameter("descripcion")); 
	  cdo1.addColValue("nombre",request.getParameter("nombre")); 
	  cdo1.addColValue("tipo",request.getParameter("tipo")); 
	  cdo1.addColValue("status",request.getParameter("status")); 
	 
	  if (mode.equalsIgnoreCase("add"))
	  {
		
			cdo1.setAutoIncCol("id");
			cdo1.addPkColValue("id","");
			
		SQLMgr.insert(cdo1);
		id = SQLMgr.getPkColValue("id");
	  }
	  else
	  {
	   cdo1.setWhereClause("id="+request.getParameter("id"));
	
		SQLMgr.update(cdo1);
	  }
  }
  if (tab.equals("1")) //centros de servicio
  {
 	int size = 0;
    if (request.getParameter("size") != null) size = Integer.parseInt(request.getParameter("size"));
    String itemRemoved = "",removedItem ="";
		al.clear();
		for (int i=0; i< size; i++)
		{
				CommonDataObject cdo = new CommonDataObject();
				cdo.setTableName("tbl_sal_guia_cds");
				
				cdo.setWhereClause("cod_guia="+id+" ");
					cdo.setAutoIncCol("codigo");
					cdo.setAutoIncWhereClause("cod_guia="+id+" ");

				cdo.addColValue("cod_guia",""+id);
				cdo.addColValue("cds",request.getParameter("cds"+i));
				cdo.addColValue("descripcion",request.getParameter("descripcion"+i));
				cdo.addColValue("estado",request.getParameter("estado"+i));
				cdo.addColValue("status",request.getParameter("status"+i));
				
				if (baction.trim().equalsIgnoreCase("Guardar") && cdo.getColValue("status").trim().equals("D"))cdo.addColValue("estado","I");
				
				
				key = request.getParameter("key"+i);

				if (request.getParameter("remove"+i) != null && !request.getParameter("remove"+i).equals(""))
				{
					cdo.addColValue("status","D");
					itemRemoved = key;
					
				}
				
				 try
					{

						al.add(cdo);
						iCds.put(key,cdo);
					}
					catch(Exception e)
					{
						System.err.println(e.getMessage());
					}

		}
		if(!itemRemoved.equals(""))
		{
			//vDiagPre.remove(removedItem);
			//iDiagPre.remove(itemRemoved);
			response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&tab=1&mode="+mode+"&cdsLastLineNo="+cdsLastLineNo+"&id="+id);

return;

		}

		if(baction.equals("+"))//Agregar
		{
				response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&type=1&tab=1&mode="+mode+"&cdsLastLineNo="+cdsLastLineNo+"&id="+id);
				return;
		}

		if (baction.equalsIgnoreCase("Guardar"))
		{
			if (al.size() == 0)
			{
				CommonDataObject cdo = new CommonDataObject();

				cdo.setTableName("tbl_sal_guia_cds");
				cdo.setWhereClause("cod_guia="+id+" ");

				al.add(cdo);
			}
			ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
			SQLMgr.insertList(al);
			ConMgr.clearAppCtx(null);
		}

	}//END TAB 1
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
	if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/expediente/guiaCuidados_list.jsp"))
	{
%>
	window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/expediente/guiaCuidados_list.jsp")%>';
<%
	}
	else
	{
%>
	window.opener.location = '<%=request.getContextPath()%>/expediente/guiaCuidados_list.jsp';
<%
	}

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
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?mode=edit&id=<%=id%>&tab=<%=tab%>';
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>