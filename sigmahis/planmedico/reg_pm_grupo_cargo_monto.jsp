<%//@ page errorPage="../error.jsp"%>
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
<jsp:useBean id="iGrupoCargoMonto" scope="session" class="java.util.Hashtable" />
<%

SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");

UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);
String sql = "";
String mode = request.getParameter("mode");
String codigo = request.getParameter("codigo");
String desc = request.getParameter("desc");
String grupo = request.getParameter("grupo");
String change = request.getParameter("change");
String compania = (String) session.getAttribute("_companyId");
String key = "";
String cDate = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String cUserName = UserDet.getUserName();

ArrayList al = new ArrayList();
StringBuffer sbSql = new StringBuffer();

int grupoCargoMontoLLastLineNo = 0;

if (mode == null) mode = "add";
if (codigo==null) codigo = "0";
if (desc==null) desc = "";
if (grupo==null) grupo = "";

if (request.getParameter("grupoCargoMontoLLastLineNo") != null) grupoCargoMontoLLastLineNo = Integer.parseInt(request.getParameter("grupoCargoMontoLLastLineNo"));

if (request.getMethod().equalsIgnoreCase("GET"))
{ 
  if (mode.equalsIgnoreCase("view") || mode.equalsIgnoreCase("edit")){
     
  }else{
    
  }
	CommonDataObject cdo = new CommonDataObject();
	
	if (change == null){
	
	   iGrupoCargoMonto.clear();
	   
       if (mode.equals("view") || mode.equals("edit")){
           sbSql.append(" select p.monto, p.id_copago, p.tipo_plan from tbl_pm_plan_copago p where p.id_copago = ");
           sbSql.append(codigo);
           sbSql.append(" order by p.tipo_plan ");
               
           al = SQLMgr.getDataList(sbSql.toString());
       }

	   grupoCargoMontoLLastLineNo = al.size();

	   for (int i=0; i<al.size(); i++){
			cdo = (CommonDataObject) al.get(i);
			cdo.setAction("U");
			cdo.setKey(i);

			try
			{
				iGrupoCargoMonto.put(cdo.getKey(), cdo);
			}
			catch(Exception e)
			{
				System.err.println(e.getMessage());
			}
		}//for i

		
		if (al.size() == 0){
			cdo = new CommonDataObject();
            cdo.addColValue("codigo",codigo);
            cdo.addColValue("desc", desc);
            cdo.addColValue("grupo", grupo);
			cdo.setKey(iGrupoCargoMonto.size()+1);
			cdo.addColValue("key",key);
			cdo.setAction("I");

			try
			{
				iGrupoCargoMonto.put(cdo.getKey(), cdo);
			}
			catch(Exception e)
			{
				System.err.println(e.getMessage());
			}
            
            mode = "add";
		}
			
	}// change == null
    
    boolean viewMode = mode.equals("view");
	
%>
<!doctype html>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script>
function doAction(){
  <%if (request.getParameter("type") != null){%>
  <%}%>
}
$(document).ready(function(){
   $(".btnRem").click(function(c){
	 var i = $(this).data("i");
	 removeItem('form0',i);
	 $("#form0").submit();
   });
});

function canSubmit(){
   var s = $("#grupoCargoSize").val() || 0;
   
   __continue = true;
   
   for (var i = 0; i<s; i++){
      var desc = $("#descripcion"+i).val();
      var codigo = $("#codigo"+i).val() || 0;
      
      if (!codigo) {CBMSG.error("Por favor ingrese el código."); __continue = false; return false;}
      if (!desc) {CBMSG.error("Por favor ingrese la descripción."); __continue = false; return false;}
   }
   if( __continue) {
     $("#baction").val("Guardar");
     $("#form0").submit();
   }
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">

<table align="center" width="99%" cellpadding="1" cellspacing="0">
    <tr class="TextRow02"><td>&nbsp;</td></tr>
    <tr class="TextHeader"><td>GRUPO CARGO</td></tr>
    <tr class="TextRow02"><td>&nbsp;</td></tr>
	<tr>
		<td class="TableBorder">
        
		  <table align="center" width="100%" cellpadding="0" cellspacing="1">
			<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
			<%=fb.formStart(true)%>
			<%fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value!='Guardar')return true;");%>
			<%=fb.hidden("mode",mode)%>
			<%=fb.hidden("baction","")%>
			<%=fb.hidden("codigo",codigo)%>
			<%=fb.hidden("grupoCargoSize",""+iGrupoCargoMonto.size())%>
			<%=fb.hidden("grupoCargoMontoLLastLineNo",""+grupoCargoMontoLLastLineNo)%>
			<%=fb.hidden("desc", desc)%>
			<%=fb.hidden("grupo", grupo)%>
            
			 <tr class="TextHeader02">
				<td width='15%'><cellbytelabel>ID Copago</cellbytelabel></td>
				<td width='40%'><cellbytelabel>Descripci&oacute;n</cellbytelabel></td>
				<td width='15%' align="center"><cellbytelabel>Grupo</cellbytelabel></td>
				<td width='15%' align="center"><cellbytelabel>Tipo Plan</cellbytelabel></td>
				<td width='10%' align="center"><cellbytelabel>Monto</cellbytelabel></td>
				<td width="5%" align="center">
				<% String form = "'"+fb.getFormName()+"'";%>
				<%=fb.submit("btnAdd","+",false,viewMode,null,null,"onClick=\"javascript:setBAction("+form+",this.value)\"","Agregar Facturas")%>
				</td>
			 </tr>

					<%
						al = CmnMgr.reverseRecords(iGrupoCargoMonto);
						for (int i=0; i<iGrupoCargoMonto.size(); i++)
						{
							key = al.get(i).toString();
							CommonDataObject cdoLiqRcl = (CommonDataObject) iGrupoCargoMonto.get(key);
							boolean locked = cdoLiqRcl.getColValue("lockedd")!=null && !cdoLiqRcl.getColValue("lockedd").equals("")&& !cdoLiqRcl.getColValue("lockedd").equals("0");
                     %>
                        
						<tr class="TextRow01" id="row<%=i%>">
							<td><%=fb.textBox("codigo"+i, codigo,false,false,true,15,"",null,null)%></td>
							<td><%=fb.textBox("descripcion"+i, desc,false,false,true,50,"",null,null)%></td>
							
                            <td align="center">
                            <%=fb.select("grupo"+i,"C=Consulta,H=Hospitalización",grupo,false,true,0,null,null,null,null,"")%>
                            </td>
                            
                            <td align="center">
                            <%=fb.select("tipo_plan"+i,"1=Familiar,2=Tercera Edad",cdoLiqRcl.getColValue("tipo_plan"),false,false,0,null,null,null,null,"")%>
                            </td>
                            
                            <td align="center"><%=fb.textBox("monto"+i, cdoLiqRcl.getColValue("monto"),true,false,viewMode,8,"",null,null)%></td>
										
							<td align="center"><%=fb.button("rem"+i,"X",true,viewMode,"btnRem",cdoLiqRcl.getAction().equals("D")?"color:red":"","","Eliminar"," data-i='"+i+"'")%></td>
						</tr>
						<%=fb.hidden("key"+i,cdoLiqRcl.getKey())%>
						<%=fb.hidden("remove"+i,"")%>			
						<%=fb.hidden("action"+i,cdoLiqRcl.getAction())%>			
						<%=fb.hidden("lockedd"+i,cdoLiqRcl.getColValue("lockedd"))%>			
					 <%}%>
                     
                     <tr class="TextRow01">
                        <td align="right" colspan='7'>&nbsp;</td>
				     </tr>
                     
                     <tr class="TextRow02">
                        <td align="right" colspan='7'>
                            <%=fb.button("save","Guardar",true,viewMode,null,null,"onclick=\"canSubmit()\"")%>
                            <%//=fb.button("close","Cerrar",true,false,null,null,"onclick=\"window.close()\"")%>
                        </td>
				     </tr>

			<%=fb.formEnd(true)%>
			</table> 
		</td>
	</tr>
	
</table>
</body>
</html>
<%
}//GET
else
{
	String baction = request.getParameter("baction");
	int size = Integer.parseInt(request.getParameter("grupoCargoSize")==null?"0":request.getParameter("grupoCargoSize"));
	String errCode = "";
	String errMsg = "";
    
    System.out.println(":::::::::::::::::::::::::::::::::::::::::::::::::::::::: POSTING "+size);

	String itemRemoved = "";
		
	al.clear();
	iGrupoCargoMonto.clear();
    
	for (int i=0; i<size; i++)
	{
		CommonDataObject cdo = new CommonDataObject();
        cdo.setTableName("tbl_pm_plan_copago");
        
		cdo.addColValue("key",request.getParameter("key"+i));
		cdo.setKey(i);
		cdo.setAction(request.getParameter("action"+i));
        
        if (cdo.getAction().equalsIgnoreCase("I")) {
          cdo.addColValue("id_copago", codigo);
        }
        cdo.addColValue("tipo_plan", request.getParameter("tipo_plan"+i));
        cdo.addColValue("monto", request.getParameter("monto"+i));
        
        if (cdo.getAction().equalsIgnoreCase("U")) {
          cdo.addColValue("fecha_modificacion", cDate);
          cdo.addColValue("usuario_modificacion", cUserName);
          cdo.setWhereClause("id_copago = "+codigo+" and tipo_plan = "+request.getParameter("tipo_plan"+i));
        }
		
		if (request.getParameter("remove"+i) != null && !request.getParameter("remove"+i).equals("")){
		    itemRemoved = cdo.getKey();
		    if (cdo.getAction().equalsIgnoreCase("I")) cdo.setAction("X");
			else cdo.setAction("D");
		}
				
		if (!cdo.getAction().equalsIgnoreCase("X"))
		{
			try
			{
				iGrupoCargoMonto.put(cdo.getKey(),cdo);
				al.add(cdo);
			}
			catch(Exception e)
			{
				System.err.println(e.getMessage());
			}
		}

	}
	
	if (!itemRemoved.equals("")){
		response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&codigo="+codigo+"&desc="+desc+"&grupo="+grupo);
		return;
	}
	
	if (baction != null && baction.equals("+"))
	{
		CommonDataObject cdo = new CommonDataObject();
		grupoCargoMontoLLastLineNo++;
		
		cdo.setKey(iGrupoCargoMonto.size()+1);
		cdo.setAction("I");
		cdo.addColValue("codigo", codigo);
		cdo.addColValue("desc", desc);
		cdo.addColValue("grupo", grupo);
		cdo.addColValue("lockedd","0");
		try
		{
			iGrupoCargoMonto.put(cdo.getKey(), cdo);
		}
		catch(Exception e)
		{
			System.err.println(e.getMessage());
		}
		
		response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&codigo="+codigo+"&desc="+desc+"&grupo="+grupo);
		return;
	}

	if(baction != null && baction.equals("Guardar"))
	{
		if (al.size() == 0)
		{
			CommonDataObject cdo = new CommonDataObject();
			cdo.setAction("I");
			al.add(cdo);
		}
		
		//ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
		SQLMgr.saveList(al,true);
        //ConMgr.clearAppCtx(null);
	}
%>
<!DOCTYPE html>
<html>
<head>
<script>
function closeWindow()
{
<%
if (SQLMgr.getErrCode().equals("1"))
{
%>
	alert('<%=SQLMgr.getErrMsg()%>');
	parent.window.location = '<%=request.getContextPath()%>/planmedico/pm_grupo_cargo_list.jsp?beginSearch=&estado=A';
    parent.hidePopWin(false);
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