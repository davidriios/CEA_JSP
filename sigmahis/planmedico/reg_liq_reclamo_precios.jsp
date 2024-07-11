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
<jsp:useBean id="iLiqReclPrecio" scope="session" class="java.util.Hashtable" />
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
String id = request.getParameter("id");
String change = request.getParameter("change");
int liqReclLastLineNo = 0;
String key = "";

if (request.getParameter("liqReclLastLineNo")!=null && !request.getParameter("liqReclLastLineNo").equals("")) liqReclLastLineNo = Integer.parseInt(request.getParameter("liqReclLastLineNo"));

ArrayList al = new ArrayList();
StringBuffer sbSql = new StringBuffer();

if (mode == null) mode = "add";
if (id==null) id = "0";

if (request.getMethod().equalsIgnoreCase("GET"))
{ 
  if (mode.equalsIgnoreCase("view") || mode.equalsIgnoreCase("edit")){
     
  }else{
    
  }
	CommonDataObject cdo = new CommonDataObject();
	
	if (change == null){
	
	   iLiqReclPrecio.clear();
	   
       if (mode.equals("view") || mode.equals("edit")){
           sbSql.append(" select l.id, l.codigo_precio, l.descripcion, l.precio, decode(l.estado,'A','Activo','Inactivo') estado_desc, id_clasif from tbl_pm_lista_precios l where id = ");
           sbSql.append(id);
           sbSql.append(" order by 1 ");
               
           al = SQLMgr.getDataList(sbSql.toString());
       }

	   liqReclLastLineNo = al.size();

	   for (int i=0; i<al.size(); i++){
			cdo = (CommonDataObject) al.get(i);
			cdo.setAction("U");
			cdo.setKey(i);

			try
			{
				iLiqReclPrecio.put(cdo.getKey(), cdo);
			}
			catch(Exception e)
			{
				System.err.println(e.getMessage());
			}
		}//for i

		
		if (al.size() == 0){
			cdo = new CommonDataObject();
            cdo.addColValue("codigo_precio","0");
            cdo.addColValue("id","0");
			cdo.setKey(iLiqReclPrecio.size()+1);
			cdo.addColValue("key",key);
			cdo.setAction("I");

			try
			{
				iLiqReclPrecio.put(cdo.getKey(), cdo);
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
   var s = $("#liqReclPrecioSize").val() || 0;
   
   __continue = true;
   
   for (var i = 0; i<s; i++){
      var desc = $("#descripcion"+i).val();
      var codigoPrecio = $("#codigo_precio"+i).val() || 0;
      var precio = $("#precio"+i).val() || 0;
      
      if (!codigoPrecio) {CBMSG.error("Por favor ingrese el código."); __continue = false; return false;}
      if (!desc) {CBMSG.error("Por favor ingrese la descripción."); __continue = false; return false;}
      if (!precio) {CBMSG.error("Por favor ingrese el precio."); __continue = false; return false;} 
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
    <tr class="TextHeader"><td>LISTA DE PRECIOS</td></tr>
    <tr class="TextRow02"><td>&nbsp;</td></tr>
	<tr>
		<td class="TableBorder">
        
		  <table align="center" width="100%" cellpadding="0" cellspacing="1">
			<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
			<%=fb.formStart(true)%>
			<%fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value!='Guardar')return true;");%>
			<%=fb.hidden("mode",mode)%>
			<%=fb.hidden("baction","")%>
			<%=fb.hidden("id",id)%>
			<%=fb.hidden("liqReclPrecioSize",""+iLiqReclPrecio.size())%>
			<%=fb.hidden("liqReclLastLineNo",""+liqReclLastLineNo)%>
            
			 <tr class="TextHeader02">
				<td width='15%'><cellbytelabel>C&oacute;digo</cellbytelabel></td>
				<td width='50%'><cellbytelabel>Descripci&oacute;n</cellbytelabel></td>
				<td width='15%'><cellbytelabel>Precio</cellbytelabel></td>
				<td width='15%' align="center"><cellbytelabel>Estado</cellbytelabel></td>
				<td width='15%' align="center"><cellbytelabel>Clasificaci&oacute;n</cellbytelabel></td>
				<td width="5%" align="center">
				<% String form = "'"+fb.getFormName()+"'";%>
				<%=fb.submit("btnAdd","+",false,viewMode,null,null,"onClick=\"javascript:setBAction("+form+",this.value)\"","Agregar Facturas")%>
				</td>
			 </tr>

					<%
						al = CmnMgr.reverseRecords(iLiqReclPrecio);
						for (int i=0; i<iLiqReclPrecio.size(); i++)
						{
							key = al.get(i).toString();
							CommonDataObject cdoLiqRcl = (CommonDataObject) iLiqReclPrecio.get(key);
							boolean locked = cdoLiqRcl.getColValue("lockedd")!=null && !cdoLiqRcl.getColValue("lockedd").equals("")&& !cdoLiqRcl.getColValue("lockedd").equals("0");
                     %>
                        
						<tr class="TextRow01" id="row<%=i%>">
							<td><%=fb.textBox("codigo_precio"+i,cdoLiqRcl.getColValue("codigo_precio"),true,false,(cdoLiqRcl.getColValue("codigo_precio")!=null&&(cdoLiqRcl.getColValue("codigo_precio").equals("-01") || cdoLiqRcl.getColValue("codigo_precio").equals("-02")||cdoLiqRcl.getColValue("codigo_precio").equals("-07")))||viewMode,10,15,"",null,null)%></td>
							<td><%=fb.textBox("descripcion"+i,cdoLiqRcl.getColValue("descripcion"),true,false,viewMode,70,255,"",null,null)%></td>
							
							<td align="left"><%=fb.decBox("precio"+i,cdoLiqRcl.getColValue("precio"),true,false,viewMode,10,10.2,"",null,null)%></td>

							<td align="center">
							<%=fb.select("estado"+i,"A=Activo,I=Inactivo",cdoLiqRcl.getColValue("estado"),false,false,0,null,null,null,null,"")%>
							</td>
							<td align="center">
							<%=fb.select(ConMgr.getConnection(),"select id as optValueColumn, codigo||' - '||descripcion as optLabelColumn from tbl_pm_clasif_lista_precio order by codigo","id_clasif"+i,cdoLiqRcl.getColValue("id_clasif"),false,false,0,"Text10",null,null)%>
							</td>
										
							<td align="center"><%=fb.button("rem"+i,"X",true,viewMode,"btnRem",cdoLiqRcl.getAction().equals("D")?"color:red":"","","Eliminar"," data-i='"+i+"'")%></td>
						</tr>
						<%=fb.hidden("key"+i,cdoLiqRcl.getKey())%>
						<%=fb.hidden("remove"+i,"")%>			
						<%=fb.hidden("action"+i,cdoLiqRcl.getAction())%>			
						<%=fb.hidden("id"+i, cdoLiqRcl.getColValue("id"))%>			
						<%=fb.hidden("lockedd"+i,cdoLiqRcl.getColValue("lockedd"))%>			
					 <%}%>
                     
                     <tr class="TextRow01">
                        <td align="right" colspan='5'>&nbsp;</td>
				     </tr>
                     
                     <tr class="TextRow02">
                        <td align="right" colspan='5'>
                            <%=fb.button("save","Guardar",true,viewMode,null,null,"onclick=\"canSubmit()\"")%>
                            &nbsp;&nbsp;&nbsp;
                            <%=fb.button("close","Cerrar",true,false,null,null,"onclick=\"window.close()\"")%>
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
	int size = Integer.parseInt(request.getParameter("liqReclPrecioSize")==null?"0":request.getParameter("liqReclPrecioSize"));
	String errCode = "";
	String errMsg = "";
    
	String itemRemoved = "";
		
	al.clear();
	iLiqReclPrecio.clear();
    
	for (int i=0; i<size; i++)
	{
		CommonDataObject cdo = new CommonDataObject();
        cdo.setTableName("tbl_pm_lista_precios");
        cdo.setAutoIncCol("id");
        
        cdo.addColValue("codigo_precio",request.getParameter("codigo_precio"+i));
        cdo.addColValue("estado",request.getParameter("estado"+i));
        cdo.addColValue("descripcion",request.getParameter("descripcion"+i));
        cdo.addColValue("precio",request.getParameter("precio"+i));
        cdo.addColValue("id_clasif",request.getParameter("id_clasif"+i));
        
		cdo.addColValue("key",request.getParameter("key"+i));
		cdo.setKey(i);
		cdo.setAction(request.getParameter("action"+i));
        
        if (cdo.getAction() != null && cdo.getAction().trim().equalsIgnoreCase("U")) {
            cdo.setWhereClause("id = "+request.getParameter("id"+i));
            cdo.addColValue("id",request.getParameter("id"+i));
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
				iLiqReclPrecio.put(cdo.getKey(),cdo);
				al.add(cdo);
			}
			catch(Exception e)
			{
				System.err.println(e.getMessage());
			}
		}

	}
	
	if (!itemRemoved.equals("")){
		response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&mode="+mode);
		return;
	}
	
	if (baction != null && baction.equals("+"))
	{
		CommonDataObject cdo = new CommonDataObject();
		liqReclLastLineNo++;
		
		cdo.setKey(iLiqReclPrecio.size()+1);
		cdo.setAction("I");
		cdo.addColValue("id","0");
		cdo.addColValue("codigo_precio","0");
		cdo.addColValue("lockedd","0");
		try
		{
			iLiqReclPrecio.put(cdo.getKey(), cdo);
		}
		catch(Exception e)
		{
			System.err.println(e.getMessage());
		}
		
		response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&mode="+mode);
		return;
	}

	if(baction != null && baction.equals("Guardar"))
	{
		if (al.size() == 0)
		{
			CommonDataObject cdo = new CommonDataObject();
			cdo.setAction("I");
            cdo.addColValue("id","0");
            cdo.addColValue("codigo_precio","0");
			al.add(cdo);
		}
		
		ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
		SQLMgr.saveList(al,true);
        ConMgr.clearAppCtx(null);
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
	window.opener.location = '<%=request.getContextPath()%>/planmedico/liq_reclamo_precios_list.jsp';
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