<%//@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.CommonDataObject"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="HashDet" scope="session" class="java.util.Hashtable" />
<%
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");

UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
ArrayList lista = new ArrayList();
String mode = request.getParameter("mode");
String id = request.getParameter("id");

String key = "";
String sql = "";
int lastLineNo = 0;

fb = new FormBean("formSub",request.getContextPath()+request.getServletPath(),FormBean.POST);

if (request.getParameter("lastLineNo") != null && !request.getParameter("lastLineNo").equals("")) lastLineNo = Integer.parseInt(request.getParameter("lastLineNo"));
else lastLineNo = 0;


if (request.getMethod().equalsIgnoreCase("GET"))
{  
%>
<html>   
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript">
document.title = 'SubTipos de Dietas - '+document.title;

function doSubmit()
{
    if ( parent.document.form0.tubo.checked == true ){
         document.formSub.tipoTubo.value = 'S';
   } else {
	    document.formSub.tipoTubo.value = 'N';	
   }			 
	
   document.formSub.tipoDesc.value = parent.document.form0.descripcion.value;
   document.formSub.tipoObserv.value = parent.document.form0.observacion.value;
   document.formSub.status.value = parent.document.form0.status.value;
	 //document.formSub.codDieta.value = parent.document.form0.id.value;
 
   if (formSubValidation())
   {
      document.formSub.submit(); 
   } 
}
function newHeight()
{
  if (parent.adjustIFrameSize) parent.adjustIFrameSize(window);
}
function setBAction(fName,actionValue)
{
	document.forms[fName].baction.value = actionValue;
}
function removeItem(fName,k)
{
	var rem = eval('document.'+fName+'.rem'+k).value;
	eval('document.'+fName+'.remove'+k).value = rem;
	setBAction(fName,rem);
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="newHeight();">
<table align="center" width="100%" cellpadding="0" cellspacing="0">
	<tr>
		<td class="TableBorder">
			<table align="center" width="100%" cellpadding="0" cellspacing="1">		

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->

			<%=fb.formStart(true)%>	
			<%=fb.hidden("baction","")%>	
			<%=fb.hidden("lastLineNo",""+lastLineNo)%>
			<%=fb.hidden("mode", mode)%>
			<%=fb.hidden("codigo", "")%>
			<%=fb.hidden("codDieta",id)%>
			<%=fb.hidden("keySize",""+HashDet.size())%>			
			<%=fb.hidden("tipoDesc", "")%>
			<%=fb.hidden("tipoTubo", "")%>
			<%=fb.hidden("tipoObserv", "")%>
			<%=fb.hidden("status", "")%>
			    
				<tr class="TextRow02">
					<td colspan="5" align="right">
					<%
						//if (SecMgr.checkAccess(session.getId(),"0") || SecMgr.checkAccess(session.getId(),"900098"))
						//{
					%>
					     <%=fb.submit("addCol","Agregar",true,false,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"","Agregar")%>
					<%
					   // }
					%>
					</td>
				</tr>	
			    <tr class="TextHeader" align="center">
					<td width="10%"><cellbytelabel id="1">C&oacute;digo</cellbytelabel></td>
					<td width="35%"><cellbytelabel id="2">Descripci&oacute;n</cellbytelabel></td>							
					<td width="40%"><cellbytelabel id="3">Observaci&oacute;n</cellbytelabel></td>				
					<td width="10%"><cellbytelabel id="3">Estado</cellbytelabel></td>				
					<td width="5%">&nbsp;</td>
				</tr>			
				<%	
				    String js = "",display="";		  
				    al = CmnMgr.reverseRecords(HashDet);				
				    for (int i = 1; i <= HashDet.size(); i++)
				    {
					  key = al.get(i - 1).toString();									  
				   	  CommonDataObject std = (CommonDataObject) HashDet.get(key);		
							//if(std.getStatus().trim().equals("A"))
							//display = "style=display:inline";		  					  
			    %>		
					
				<tr class="TextRow01" <%=display%>>
				<%=fb.hidden("key"+i,key)%>
				<%=fb.hidden("remove"+i,"")%>	
				<%=fb.hidden("codigo"+i, std.getColValue("codigo"))%>
					<td><%=fb.intBox("codigo_dsp"+i, std.getColValue("codigo_dsp"),false,false,true,15)%></td>
					<td><%=fb.textBox("descripcion"+i, std.getColValue("descripcion"),true,false,false,45,200)%></td>        
					<td><%=fb.textBox("observacion"+i, std.getColValue("observacion"),false,false,false,55,2000)%></td>					
					<td><%=fb.select("status"+i,"A=Activo,I=Inactivo",std.getColValue("status"),false,false,0,"",null,null,"","")%></td>					
					<td align="center"><%=fb.submit("rem"+i,"X",true,true,null,null,"onClick=\"javascript:removeItem('"+fb.getFormName()+"',"+i+")\"")%></td>						
				</tr>
				<%	
				     //Si error--, quita el error. Si error++, agrega el error. 
				     js += "if(document."+fb.getFormName()+".descripcion"+i+".value=='')error--;";
					}
					fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value!='Guardar'){"+js+"}");					
				%>  				 	
            <%=fb.formEnd(true)%>
			
<!-- ================================   F O R M   E N D   H E R E   ================================ -->

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
	System.out.println(";;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;");
	int keySize=Integer.parseInt(request.getParameter("keySize"));	   
	mode = request.getParameter("mode");
	id = request.getParameter("codDieta");
	lastLineNo = Integer.parseInt(request.getParameter("lastLineNo"));
	String ItemRemoved = "";
	
	String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
	
	CommonDataObject cdo = new CommonDataObject();
	cdo.setTableName("TBL_CDS_TIPO_DIETA");
	cdo.addColValue("descripcion", request.getParameter("tipoDesc"));
	cdo.addColValue("tubo", request.getParameter("tipoTubo"));
	cdo.addColValue("status", request.getParameter("status"));

	if (request.getParameter("tipoObserv") != null) cdo.addColValue("observacion", request.getParameter("tipoObserv"));				
	
	if (!id.trim().equals("0")) {
		cdo.setAction("U");
		cdo.setWhereClause("codigo = "+id);
		cdo.addColValue("usuario_modificacion", (String) session.getAttribute("_userName"));
		cdo.addColValue("fecha_modificacion", cDateTime);
		cdo.addColValue("codigo", id);
	} else {
		CommonDataObject cdoH = SQLMgr.getData("select nvl(max(codigo),0)+1 as nextId from TBL_CDS_TIPO_DIETA");

		cdo.addColValue("codigo", cdoH.getColValue("nextId","0"));
		cdo.setAction("I");
		cdo.addColValue("usuario_creacion", (String) session.getAttribute("_userName"));
		cdo.addColValue("fecha_creacion", cDateTime);
		cdo.addColValue("usuario_modificacion", (String) session.getAttribute("_userName"));
		cdo.addColValue("fecha_modificacion", cDateTime);
	}
	
	al.clear();
	
	for (int i=1; i<=keySize; i++) {
	    CommonDataObject cdoDet = new CommonDataObject();
		cdoDet.setTableName("TBL_CDS_SUBTIPO_DIETA");
		
		if (!request.getParameter("codigo_dsp"+i).equals("0")) {
			cdoDet.setAction("U");
			cdoDet.setWhereClause("cod_tipo_dieta = "+id+" and codigo = "+request.getParameter("codigo_dsp"+i));
			cdoDet.addColValue("usuario_modificacion", (String) session.getAttribute("_userName"));
			cdoDet.addColValue("fecha_modificacion", cDateTime);
		} else {
			cdoDet.addColValue("codigo", "(select nvl(max(codigo),0)+1 from TBL_CDS_SUBTIPO_DIETA where COD_TIPO_DIETA = "+cdo.getColValue("codigo")+")");
			cdoDet.setAction("I");
			cdoDet.addColValue("codigo_dsp", "0");
			cdoDet.addColValue("COD_TIPO_DIETA", cdo.getColValue("codigo"));
			cdoDet.addColValue("usuario_creacion", (String) session.getAttribute("_userName"));
			cdoDet.addColValue("fecha_creacion", cDateTime);
			cdoDet.addColValue("usuario_modificacion", (String) session.getAttribute("_userName"));
			cdoDet.addColValue("fecha_modificacion", cDateTime);
		}
		
		cdoDet.addColValue("codigo_dsp", request.getParameter("codigo_dsp"+i));
		cdoDet.addColValue("descripcion", request.getParameter("descripcion"+i));
		cdoDet.addColValue("status", request.getParameter("status"+i));
		
    	if (request.getParameter("observacion"+i) != null) cdoDet.addColValue("observacion", request.getParameter("observacion"+i));
	    key = request.getParameter("key"+i);
		
		if (request.getParameter("remove"+i) != null && !request.getParameter("remove"+i).equals("")){ 		  
		  ItemRemoved = key;		 
		  cdoDet.setAction("D");//delete
		} else {
		  try
			{ 
			HashDet.put(key, cdoDet);
			al.add(cdoDet);
		 }catch(Exception e){ System.err.println(e.getMessage()); }			    	       
	   }
	  }//for	
	
	  if (!ItemRemoved.equals(""))
	  {
	  	 HashDet.remove(ItemRemoved);
		 response.sendRedirect("../expediente/subtipos_dieta_config.jsp?mode="+mode+"&lastLineNo="+lastLineNo+"&id="+id);
		 return;
	  }
	  
	  if ((request.getParameter("baction") != null && request.getParameter("baction").equals("Agregar")) || al.size() < 1)
	  {	
		CommonDataObject cdoDet = new CommonDataObject();
		cdoDet.setTableName("TBL_CDS_SUBTIPO_DIETA");
				
		++lastLineNo;
	    if (lastLineNo < 10) key = "00" + lastLineNo;
	    else if (lastLineNo < 100) key = "0" + lastLineNo;
	    else key = "" + lastLineNo;
		
		cdoDet.addColValue("codigo", "0");
		cdoDet.addColValue("codigo_dsp", "0");
		cdoDet.setAction("I");
		try{ 
		     HashDet.put(key, cdoDet);
		   }catch(Exception e){ System.err.println(e.getMessage()); }	 
		response.sendRedirect("../expediente/subtipos_dieta_config.jsp?mode="+mode+"&lastLineNo="+lastLineNo+"&id="+id);
		return;
	  }
	  
	  ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
	  SQLMgr.save(cdo,al,true,false,true,true);
	  if (mode.equals("add")) {
		id = cdo.getColValue("codigo");
	  }
	  ConMgr.clearAppCtx(null);
%>
<html>
<head>
<script>
function closeWindow()
{
  parent.document.form0.errCode.value = '<%=SQLMgr.getErrCode()%>';
  parent.document.form0.errMsg.value = '<%=SQLMgr.getErrMsg()%>';
  parent.document.form0.id.value = '<%=id%>';
  parent.document.form0.submit(); 
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>