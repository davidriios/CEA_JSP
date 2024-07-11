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
<jsp:useBean id="iGrupoCargo" scope="session" class="java.util.Hashtable" />
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
String change = request.getParameter("change");
String compania = (String) session.getAttribute("_companyId");
String key = "";
String cDate = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String cUserName = UserDet.getUserName();

ArrayList al = new ArrayList();
StringBuffer sbSql = new StringBuffer();

int grupoCargoLLastLineNo = 0;

if (mode == null) mode = "add";
if (codigo==null) codigo = "0";

if (request.getParameter("grupoCargoLLastLineNo") != null) grupoCargoLLastLineNo = Integer.parseInt(request.getParameter("grupoCargoLLastLineNo"));

if (request.getMethod().equalsIgnoreCase("GET"))
{ 
  if (mode.equalsIgnoreCase("view") || mode.equalsIgnoreCase("edit")){
     
  }else{
    
  }
	CommonDataObject cdo = new CommonDataObject();
	
	if (change == null){
	
	   iGrupoCargo.clear();
	   
       if (mode.equals("view") || mode.equals("edit")){
           sbSql.append(" select gc.codigo, gc.descripcion, gc.estado, gc.grupo from tbl_pm_grupo_copago gc where gc.compania = ");
           sbSql.append(compania);
           sbSql.append(" and gc.codigo = ");
           sbSql.append(codigo);
           sbSql.append(" order by 1 ");
               
           al = SQLMgr.getDataList(sbSql.toString());
       }

	   grupoCargoLLastLineNo = al.size();

	   for (int i=0; i<al.size(); i++){
			cdo = (CommonDataObject) al.get(i);
			cdo.setAction("U");
			cdo.setKey(i);

			try
			{
				iGrupoCargo.put(cdo.getKey(), cdo);
			}
			catch(Exception e)
			{
				System.err.println(e.getMessage());
			}
		}//for i

		
		if (al.size() == 0){
			cdo = new CommonDataObject();
            cdo.addColValue("codigo","0");
			cdo.setKey(iGrupoCargo.size()+1);
			cdo.addColValue("key",key);
			cdo.setAction("I");

			try
			{
				iGrupoCargo.put(cdo.getKey(), cdo);
			}
			catch(Exception e)
			{
				System.err.println(e.getMessage());
			}
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
			<%=fb.hidden("grupoCargoSize",""+iGrupoCargo.size())%>
			<%=fb.hidden("grupoCargoLLastLineNo",""+grupoCargoLLastLineNo)%>
            
			 <tr class="TextHeader02">
				<td width='15%'><cellbytelabel>C&oacute;digo</cellbytelabel></td>
				<td width='50%'><cellbytelabel>Descripci&oacute;n</cellbytelabel></td>
				<td width='15%' align="center"><cellbytelabel>Grupo</cellbytelabel></td>
				<td width='15%' align="center"><cellbytelabel>Estado</cellbytelabel></td>
				<td width="5%" align="center">
				<% String form = "'"+fb.getFormName()+"'";%>
				<%=fb.submit("btnAdd","+",false,viewMode,null,null,"onClick=\"javascript:setBAction("+form+",this.value)\"","Agregar Facturas")%>
				</td>
			 </tr>

					<%
						al = CmnMgr.reverseRecords(iGrupoCargo);
						for (int i=0; i<iGrupoCargo.size(); i++)
						{
							key = al.get(i).toString();
							CommonDataObject cdoLiqRcl = (CommonDataObject) iGrupoCargo.get(key);
							boolean locked = cdoLiqRcl.getColValue("lockedd")!=null && !cdoLiqRcl.getColValue("lockedd").equals("")&& !cdoLiqRcl.getColValue("lockedd").equals("0");
                     %>
                        
						<tr class="TextRow01" id="row<%=i%>">
							<td><%=fb.textBox("codigo"+i,cdoLiqRcl.getColValue("codigo"),true,false,true,15,"",null,null)%></td>
							<td><%=fb.textBox("descripcion"+i,cdoLiqRcl.getColValue("descripcion"),true,false,viewMode,65,"",null,null)%></td>
							
                            <td align="center">
                            <%=fb.select("grupo"+i,"C=Consulta,H=Hospitalización",cdoLiqRcl.getColValue("grupo"),false,false,0,null,null,null,null,"")%>
                            </td>
                            
                            <td align="center">
                            <%=fb.select("estado"+i,"A=Activo,I=Inactivo",cdoLiqRcl.getColValue("estado"),false,false,0,null,null,null,null,"")%>
                            </td>
										
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
                            &nbsp;&nbsp;&nbsp;
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
	iGrupoCargo.clear();
    
	for (int i=0; i<size; i++)
	{
		CommonDataObject cdo = new CommonDataObject();
        cdo.setTableName("tbl_pm_grupo_copago");

        cdo.addColValue("estado",request.getParameter("estado"+i));
        cdo.addColValue("descripcion",request.getParameter("descripcion"+i));
        cdo.addColValue("grupo",request.getParameter("grupo"+i));
        
		cdo.addColValue("key",request.getParameter("key"+i));
		cdo.setKey(i);
		cdo.setAction(request.getParameter("action"+i));
        
        if (cdo.getAction().equalsIgnoreCase("I")) {
          cdo.setAutoIncCol("codigo");
          cdo.addColValue("fecha_creacion", cDate);
          cdo.addColValue("fecha_modificacion", cDate);
          cdo.addColValue("usuario_creacion", cUserName);
          cdo.addColValue("usuario_modificacion", cUserName);
          cdo.addColValue("compania", compania);
          cdo.addColValue("codigo", "0");
        }
        
        if (cdo.getAction().equalsIgnoreCase("U")) {
          cdo.addColValue("fecha_modificacion", cDate);
          cdo.addColValue("usuario_modificacion", cUserName);
          cdo.setWhereClause("compania = "+compania+" and codigo = "+request.getParameter("codigo"+i));
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
				iGrupoCargo.put(cdo.getKey(),cdo);
				al.add(cdo);
			}
			catch(Exception e)
			{
				System.err.println(e.getMessage());
			}
		}

	}
	
	if (!itemRemoved.equals("")){
		response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1");
		return;
	}
	
	if (baction != null && baction.equals("+"))
	{
		CommonDataObject cdo = new CommonDataObject();
		grupoCargoLLastLineNo++;
		
		cdo.setKey(iGrupoCargo.size()+1);
		cdo.setAction("I");
		cdo.addColValue("codigo","0");
		cdo.addColValue("lockedd","0");
		try
		{
			iGrupoCargo.put(cdo.getKey(), cdo);
		}
		catch(Exception e)
		{
			System.err.println(e.getMessage());
		}
		
		response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1");
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