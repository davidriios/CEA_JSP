<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Hashtable"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder"%>
<%@ page import="issi.expediente.DetallesCondicionPaciente"%>
<%@ page import="issi.expediente.CondicionPaciente"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="HashDet" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="CPMgr" scope="page" class="issi.expediente.CondicionPacienteMgr" />
<%
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");

UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
CPMgr.setConnection(ConMgr);
SQL2BeanBuilder sbb = new SQL2BeanBuilder();

ArrayList al = new ArrayList();
ArrayList lista = new ArrayList();

String mode = request.getParameter("mode");
String fg = request.getParameter("fg");
String id = request.getParameter("id");
String change = request.getParameter("change");
String codDiag = request.getParameter("cod_diag");
String key = "";
String sql = "";
int lastLineNo = 0;
if (fg == null) fg = "";
if (id == null) id = "";
if (codDiag == null) codDiag = "";

if (fg.trim().equals("")) throw new Exception("No pudimos encontrar un tipo de Condición!");

fb = new FormBean("formDetalle",request.getContextPath()+request.getServletPath(),FormBean.POST);
fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value!='Guardar')return true;");

if (request.getParameter("lastLineNo") != null && !request.getParameter("lastLineNo").equals("")) lastLineNo = Integer.parseInt(request.getParameter("lastLineNo"));
else lastLineNo = 0;
  
if (request.getMethod().equalsIgnoreCase("GET"))
{  
    if (mode.equalsIgnoreCase("add")){
       if (change == null) HashDet.clear();
    } else {
        if(change == null){
            if (fg.trim().equalsIgnoreCase("DIA")) {
                
                al = sbb.getBeanList(ConMgr.getConnection(), "SELECT codigo codigoDiag, descripcion descripcionDiag, estado estadoDiag, codigo_condicion as codigoCondicionDiag FROM tbl_sal_soapier_diagnosticos WHERE codigo_condicion = "+id+" ORDER BY codigo ASC", DetallesCondicionPaciente.class); 
                HashDet.clear();
            } else {
                al = sbb.getBeanList(ConMgr.getConnection(), "SELECT codigo, descripcion, status estado, codigo_condicion as codigoCondicion , orden FROM tbl_sal_soapier_cond_detalle WHERE codigo_condicion = "+id+" and tipo = '"+fg+"' and cod_diag = "+codDiag+" ORDER BY codigo ASC", DetallesCondicionPaciente.class); 
                HashDet.clear();
            }
			
            for (int i = 1; i <= al.size(); i++){
                if (i < 10) key = "00" + i;
                else if (i < 100) key = "0" + i;
                else key = "" + i;
                
                HashDet.put(key, al.get(i-1));
                lastLineNo = i;
            }
		}
    }
    
    Hashtable iFg = new Hashtable();
    iFg.put("DIA","DIAGNOSTICOS");
    iFg.put("MOT","MOTIVOS / CAUSA");
    iFg.put("MET","METAS");
    iFg.put("NEC","NECESIDADES");
    iFg.put("INT","INTERVENCIONES");
    
    Hashtable iOrden = new Hashtable();
    iOrden.put("MOT","1");
    iOrden.put("MET","2");
    iOrden.put("NEC","3");
    iOrden.put("INT","4");
%>
<html>   
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script>
document.title = 'Diagnosticos - '+document.title;

function doSubmit()
{
	document.formDetalle.codigo.value = parent.document.form1.id.value; 
	document.formDetalle.descripcion.value = parent.document.form1.descripcion.value; 
	document.formDetalle.plan.value = parent.document.form1.plan.value; 
	document.formDetalle.estado.value = parent.document.form1.estado.value; 
	if(formDetalleValidation()){
		
		document.formDetalle.submit(); 
	} else {
		parent.form1BlockButtons(false)
	}
}
$(function(){
  <%if (request.getParameter("lastLineNo")==null){%>
  parent.setIfUrl(window.location.href, <%=lastLineNo%>)
  <%}%>
})
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<table align="center" width="100%" cellpadding="0" cellspacing="0">
	<tr>
		<td class="TableBorder" align="center">
			<table align="center" width="100%" cellpadding="0" cellspacing="1">		
<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
			<%=fb.formStart(true)%>
			<%=fb.hidden("baction", "")%>
			<%=fb.hidden("lastLineNo",""+lastLineNo)%>
			<%=fb.hidden("mode", mode)%>
			<%=fb.hidden("keySize",""+HashDet.size())%>
			<%=fb.hidden("codigo", "")%>
			<%=fb.hidden("descripcion", "")%>
			<%=fb.hidden("plan", "")%>
			<%=fb.hidden("estado", "")%>
			<%=fb.hidden("fg", fg)%>
			<%=fb.hidden("id", id)%>
			<%=fb.hidden("ls_set", "")%>
			<%=fb.hidden("cod_diag", codDiag)%>
				<tr class="TextHeader">
                    <td colspan="3"><%=!fg.trim().equals("") ? iFg.get(fg):""%></td>
					<td align="right">
					<%=fb.submit("addCol","Agregar",true,false,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"","Agregar")%></td>
				</tr>	
			    <tr class="TextHeader" align="center">
					<td width="10%"><cellbytelabel id="1">C&oacute;digo</cellbytelabel></td>
					<td width="65%"><cellbytelabel id="2">Descripci&oacute;n</cellbytelabel></td>
					<td width="15%"><cellbytelabel id="4">Estado</cellbytelabel></td>
				    <td width="10%">&nbsp;</td>
			    </tr>			
				<%
				  if (HashDet.size() > 0) 
				  {  
				    String js = "";		
				    al = CmnMgr.reverseRecords(HashDet);				
				    for (int i = 1; i <= HashDet.size(); i++)
				    {
					  key = al.get(i - 1).toString();									  
				   	  DetallesCondicionPaciente co = (DetallesCondicionPaciente) HashDet.get(key);
			    %>
				<tr class="TextRow01" align="center">
					<%=fb.hidden("key"+i,key)%> 
					<%=fb.hidden("remove"+i,"")%>
                    <%if(!fg.trim().equalsIgnoreCase("DIA")) {%>    
					  <td><%=fb.textBox("codigo"+i, co.getCodigo(),false,false,true,5)%></td>
					  <td><%=fb.textBox("descripcion"+i, co.getDescripcion(),true,false,false,100,100)%></td>        
					  <td><%=fb.select("estado"+i,"A=ACTIVO,I=INACTIVO",co.getEstado(),false,false,0,"")%> </td>
                    <%}else{%>
                      <td><%=fb.textBox("codigo"+i, co.getCodigoDiag(),false,false,true,5)%></td>
					  <td><%=fb.textBox("descripcion"+i, co.getDescripcionDiag(),true,false,false,100,100)%></td>        
					  <td><%=fb.select("estado"+i,"A=ACTIVO,I=INACTIVO",co.getEstadoDiag(),false,false,0,"")%> </td>
                    <%}%>
                    
				    <td><%=fb.submit("rem"+i,"X",false,(!co.getCodigo().trim().equals("0")),null,null,"onClick=\"javascript:removeItem('"+fb.getFormName()+"',"+i+")\"","Eliminar")%></td>
                    <%=fb.hidden("orden"+i, co.getCodigo().trim().equals("0")?""+iOrden.get(fg):co.getOrden())%>
				</tr>
				<%	
				  }				  
					 fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value!='Guardar'){"+js+"}");	
					}
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
	  int keySize=Integer.parseInt(request.getParameter("keySize"));	   
	  mode = request.getParameter("mode");
	  lastLineNo = Integer.parseInt(request.getParameter("lastLineNo"));
	  ArrayList list = new ArrayList();	  
	  String ItemRemoved = "";
	  
	  for (int i=1; i<=keySize; i++){
	   DetallesCondicionPaciente dcp = new DetallesCondicionPaciente();
	    
       if(fg.trim().equalsIgnoreCase("DIA")) {
           dcp.setCodigoDiag(request.getParameter("codigo"+i));
           dcp.setDescripcionDiag(request.getParameter("descripcion"+i));
           dcp.setEstadoDiag(request.getParameter("estado"+i));
       } else {
           dcp.setCodigo(request.getParameter("codigo"+i));
           dcp.setDescripcion(request.getParameter("descripcion"+i));
           dcp.setOrden(request.getParameter("orden"+i));
           if(request.getParameter("estado") != null && request.getParameter("estado").trim().equals("I"))
            dcp.setEstado(request.getParameter("estado"));
           else dcp.setEstado(request.getParameter("estado"+i));
           dcp.setCodDiag(request.getParameter("cod_diag"));
           dcp.setTipo(fg);
       }
		
	    key = request.getParameter("key"+i);
		if (request.getParameter("remove"+i) != null && !request.getParameter("remove"+i).equals("")){ 
		  ItemRemoved = key;
		}
		else{
	      try{ 
           HashDet.put(key, dcp);
           list.add(dcp);
		  }catch(Exception e){ System.err.println(e.getMessage()); }     
	    }
	  }

	  if (!ItemRemoved.equals("")){
	     HashDet.remove(ItemRemoved);
		 response.sendRedirect("../expediente/exp_soapier_detalle.jsp?mode="+mode+"&lastLineNo="+lastLineNo+"&fg="+fg+"&id="+id+"&change=1&cod_diag="+codDiag);
		 return;
	  }
	  
	  if (request.getParameter("baction") != null && request.getParameter("baction").equalsIgnoreCase("Agregar")){
		DetallesCondicionPaciente dcp = new DetallesCondicionPaciente();
		
		++lastLineNo;
	    if (lastLineNo < 10) key = "00" + lastLineNo;
	    else if (lastLineNo < 100) key = "0" + lastLineNo;
	    else key = "" + lastLineNo;
		
		if(fg.trim().equalsIgnoreCase("DIA")) dcp.setCodigoDiag("0");
		else dcp.setCodigo("0");
        
		try{
		    HashDet.put(key, dcp);
            System.out.println("................................... HashDet.size() = "+HashDet.size());
		}catch(Exception e){ System.err.println(e.getMessage()); }
		response.sendRedirect("../expediente/exp_soapier_detalle.jsp?mode="+mode+"&lastLineNo="+lastLineNo+"&fg="+fg+"&id="+id+"&change=1&cod_diag="+codDiag);
		return;
	  }
		CondicionPaciente cp = new CondicionPaciente();
		cp.setCodigo(request.getParameter("codigo"));
		cp.setDescripcion(request.getParameter("descripcion"));
		cp.setPlan(request.getParameter("plan"));
		cp.setEstado(request.getParameter("estado"));
		cp.setTipo(fg);
        
		if(fg.equalsIgnoreCase("DIA")) cp.setDiagnosticos(list);
		else cp.setDetalles(list);
		
		if (mode.equalsIgnoreCase("add")){
            CPMgr.add(cp);
            id = CPMgr.getPkColValue("codigo");
		} 
		else if (mode.equalsIgnoreCase("edit")){
		   id = cp.getCodigo();
		   CPMgr.update(cp);
		}
%>
<html>
<head>
<script>
function closeWindow()
{
  <%if (CPMgr.getErrCode().equals("1")){%>
	  parent.document.form1.errCode.value = '<%=CPMgr.getErrCode()%>';
	  parent.document.form1.errMsg.value = '<%=CPMgr.getErrMsg()%>';
	  parent.document.form1.id.value = '<%=id%>';
	  parent.document.form1.submit(); 
  <%} else throw new Exception(CPMgr.getErrMsg());%>

}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>