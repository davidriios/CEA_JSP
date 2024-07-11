<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.rhplanilla.CtaPlanilla"%>
<%@ page import="issi.rhplanilla.CtaPlanillaDet"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<jsp:useBean id="ConMgr"  scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr"  scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr"  scope="page"    class="issi.admin.CommonMgr" />
<jsp:useBean id="fb"      scope="page"    class="issi.admin.FormBean" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="CtaMgr"  scope="session" class="issi.rhplanilla.CtaPlanillaMgr"/>
<jsp:useBean id="htcta"   scope="session" class="java.util.Hashtable"/>
<jsp:useBean id="vctunidad" scope="session" class="java.util.Vector" />
<%
/**
==================================================================================
==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
//if (!(SecMgr.checkAccess(session.getId(),"0") || SecMgr.checkAccess(session.getId(),"") || SecMgr.checkAccess(session.getId(),""))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);


SQLMgr.setConnection(ConMgr);
CmnMgr.setConnection(ConMgr);
CtaMgr.setConnection(ConMgr);
SQL2BeanBuilder sbb = new SQL2BeanBuilder();
ArrayList al= new ArrayList();	
ArrayList alConcep = new ArrayList();

String sql="";
String mode = request.getParameter("mode");
String cta1 = request.getParameter("cta1");
String cta2 = request.getParameter("cta2");
String cta3 = request.getParameter("cta3");
String key= "";
String change= request.getParameter("change");
int ctaLastLine=0;
boolean viewMode = false;
if (mode.equalsIgnoreCase("view")) viewMode = true;

if(request.getParameter("ctaLastLine")!= null && !request.getParameter("ctaLastLine").equals(""))
ctaLastLine=Integer.parseInt(request.getParameter("ctaLastLine"));
else ctaLastLine=0;


if (request.getMethod().equalsIgnoreCase("GET"))
{
alConcep = sbb.getBeanList(ConMgr.getConnection(),"select cod_concepto as optValueColumn, descripcion||' - '||cod_concepto as optLabelColumn, cod_concepto as optTitleColumn from tbl_pla_cuenta_concepto where cod_compania="+(String) session.getAttribute("_companyId")+" order by descripcion",CommonDataObject.class);
 
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript">
<%if (mode.equalsIgnoreCase("add")){%>
document.title="Cuentas Contables por Planilla - Agregar - "+document.title;
<%}else if (mode.equalsIgnoreCase("edit")){%>
document.title="Cuentas Contables por Planilla - Editar - "+document.title;
<%}%>
function catalagoss(k){abrir_ventana1('../common/search_catalogo_gral.jsp?fp=ctaContaPlanillahast&index='+k);}
function addSubmit(){ document.ctaDet.act.value = "add";document.ctaDet.submit(true);}
function delSubmit(index)
{
  document.ctaDet.act.value = "del";
  document.ctaDet.index.value = index;
  document.ctaDet.submit(true);
}

function doSubmit(){
		var size = <%=htcta.size()%>;
		var x = 0;
   document.ctaDet.planillaId.value = parent.document.form1.planillaId.value;
   document.ctaDet.unidadAdminId.value = parent.document.form1.unidadAdminId.value; 
   document.ctaDet.cta1.value = parent.document.form1.cuentas1.value;
   document.ctaDet.cta2.value = parent.document.form1.cuentas2.value;
   document.ctaDet.cta3.value = parent.document.form1.cuentas3.value;
   document.ctaDet.cta4.value = parent.document.form1.cuentas4.value;   
   document.ctaDet.cta5.value = parent.document.form1.cuentas5.value;
   document.ctaDet.cta6.value = parent.document.form1.cuentas6.value;
   document.ctaDet.lados.value = parent.document.form1.lado.value;
   document.ctaDet.tipo.value  = parent.document.form1.tipo.value;
   document.ctaDet.conceptoId.value = parent.document.form1.conceptoId.value; 
   document.ctaDet.id.value = parent.document.form1.id.value; 
   
   if(parent.document.form1.tipo.value=='G')
   {
   	if(parent.document.form1.cuentas1.value==''){top.CBMSG.warning('Seleccione Cuenta');x++;}
	if(parent.document.form1.conceptoId.value==''){top.CBMSG.warning('Seleccione Concepto');x++;}
	if(size !=0){top.CBMSG.warning('Elimine el detalle, Para el tipo General no es requerido agregar Detalle de Cuentas');x++;}
   }
   else
   {
   		if(parent.document.form1.unidadAdminId.value==''){top.CBMSG.warning('Seleccione Unidad');x++;}
		
   }
   
	 for(i=1;i<=size;i++){
	 		if(eval('document.ctaDet.conceptoId'+i).value==0){
				alert('Seleccione un Concepto!');
				x++;
				break;
			} else if(eval('document.ctaDet.ucta1'+i).value==0){
				alert('Seleccione Cuenta!');
				x++;
				break;
			}
	 }
   if(x==0) document.ctaDet.submit(); 
}
function validaConcepto(k)
{
var size = <%=htcta.size()%>;
var x=0; 
var concepto = eval('document.ctaDet.conceptoId'+k).value;
	if(concepto!='0')
	{ 
		for(i=1;i<=size;i++)
		{
			 if(i != k)
			{ 
				if(eval('document.ctaDet.conceptoId'+i).value == concepto){top.CBMSG.warning('Concepto ya existe seleccionado');x=x+1;}
			} 
		}
		if(x > 0){eval('document.ctaDet.conceptoId'+k).value='';}
	}
}
function doAction(){ 
	if(parent.document.form1.tipo.value=='G')
	{document.ctaDet.addCol.disabled=true; }
	else document.ctaDet.addCol.disabled=false;
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction();">

<table align="center" width="99%" cellpadding="0" cellspacing="0">
	<tr>
		<td class="TableBorder">
			<table align="center" width="99%" cellpadding="0" cellspacing="1">

<%fb = new FormBean("ctaDet",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
<%fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value!='Guardar')return true;");%>
			<%=fb.formStart(true)%>
			<%=fb.hidden("mode",mode)%>
			<%=fb.hidden("cta1","")%>
			<%=fb.hidden("cta2","")%>
			<%=fb.hidden("cta3","")%>
			<%=fb.hidden("cta4","")%>
			<%=fb.hidden("cta5","")%>
			<%=fb.hidden("cta6","")%>
			<%=fb.hidden("planillaId","")%>
			<%=fb.hidden("lados","")%>
			<%=fb.hidden("tipo","")%>
			<%=fb.hidden("unidadAdminId","")%>
			<%=fb.hidden("ctaLastLine",""+ctaLastLine)%>
			<%=fb.hidden("keySize",""+htcta.size())%>
			<%=fb.hidden("baction","")%>
			<%=fb.hidden("conceptoId","")%>
			<%=fb.hidden("conceptoIdOld","")%>
			<%=fb.hidden("id","")%>
			
			<tr>
			  	<td colspan="2">
					<table width="100%" cellpadding="1" cellspacing="1">
						<tr class="TextHeader" align="center">
							<td width="30%">&nbsp;Concepto de Cuenta</td>
							<td width="27%">Num. de la Cuenta</td>
							<td width="10%">Lado</td>
							<td width="28%">Nombre de la Cta.</td>
							<td width="5%"> <%=fb.submit("addCol","+",false,viewMode)%>
							</td>
						</tr>
						<%			
						 if(htcta.size()>0)
						 al=CmnMgr.reverseRecords(htcta);
						for(int i=1; i<=htcta.size();i++)
						
							{
								key=al.get(i-1).toString();
								CtaPlanillaDet ctasadmin= (CtaPlanillaDet) htcta.get(key) ;
								String color="";								
								if(i%2 == 0) color ="TextRow02";
								else color="TextRow01";
							%>

							<%=fb.hidden("remove"+i,"")%>
							<%=fb.hidden("key"+i,key)%>
						<tr class="TextRow01">
							
							
							<td>
							<%=fb.select("conceptoId"+i,alConcep,ctasadmin.getConceptoId(),true,false,false,0,"Text10","","onChange=\"javascript:validaConcepto("+i+")\"","","S")%>
							  
							<%//=fb.intBox("conceptoId"+i,ctasadmin.getConceptoId(),false,false,false,5)%>
							<%//=fb.textBox("conceptoName"+i,ctasadmin.getConceptoName(),false,false,false,35)%>
							<%//=fb.button("btnconcepto"+i,"...",true,false,null,null,"onClick=\"javascript:concepto("+i+");\"","Agregar Concepto")%>							
							</td>
							
							
							<td align="center">
								<%=fb.textBox("ucta1"+i,ctasadmin.getUcta1(),false,false,true,3,3,"Text10",null,null)%>
								<%=fb.textBox("ucta2"+i,ctasadmin.getUcta2(),false,false,true,2,2,"Text10",null,null)%>
								<%=fb.textBox("ucta3"+i,ctasadmin.getUcta3(),false,false,true,2,3,"Text10",null,null)%>
								<%=fb.textBox("ucta4"+i,ctasadmin.getUcta4(),false,false,true,2,3,"Text10",null,null)%>
								<%=fb.textBox("ucta5"+i,ctasadmin.getUcta5(),false,false,true,2,3,"Text10",null,null)%>
								<%=fb.textBox("ucta6"+i,ctasadmin.getUcta6(),false,false,true,2,3,"Text10",null,null)%>
							</td>
							<td align="center">
							<%=fb.select("lado"+i,"DB,CR",ctasadmin.getLado())%>
							</td>
							
							<td><%=fb.textBox("nameCuenta"+i,ctasadmin.getNameCuenta(),false,false,true,50,2000,"Text10",null,null)%>
						
							<%=fb.button("btncatalogo"+i,"...",true,false,null,null,"onClick=\"javascript:catalagoss("+i+");\"","Agregar Cuentas Administrativas")%></td>
							<td align="center"><%=fb.submit("remover"+i,"X",false,false)%>

							</td>
						</tr>
						<%}%>
					</table>
				</td>
			  </tr>
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
String saveOption = request.getParameter("saveOption");//N=Create New,O=Keep Open,C=Close
String baction = request.getParameter("baction");
String itemRemoved="";
ctaLastLine=Integer.parseInt(request.getParameter("ctaLastLine"));
ArrayList list= new ArrayList();
int keySize=Integer.parseInt(request.getParameter("keySize"));

for (int i=0; i<=keySize; i++)
{

	CtaPlanillaDet ctashast= new CtaPlanillaDet();	
	ctashast.setCompania((String)session.getAttribute("_companyId"));
	ctashast.setUsuarioCreacion((String) session.getAttribute("_userName")); 
	ctashast.setUsuarioModif((String) session.getAttribute("_userName"));
	ctashast.setConceptoId(request.getParameter("conceptoId"+i));
	ctashast.setConceptoName(request.getParameter("conceptoName"+i));
	ctashast.setUnidadAdminId(request.getParameter("unidadAdminId"));
	ctashast.setUnidadAdminName(request.getParameter("unidadAdminName"+i));
	ctashast.setUcta1(request.getParameter("ucta1"+i));
	ctashast.setUcta2(request.getParameter("ucta2"+i));
	ctashast.setUcta3(request.getParameter("ucta3"+i));  	 
	ctashast.setUcta4(request.getParameter("ucta4"+i)); 
	ctashast.setUcta5(request.getParameter("ucta5"+i));
	ctashast.setUcta6(request.getParameter("ucta6"+i));
	ctashast.setLado(request.getParameter("lado"+i));
	ctashast.setNameCuenta(request.getParameter("nameCuenta"+i));
	key = request.getParameter("key"+i);
	if (request.getParameter("remover"+i)== null)
		{
	  try
		  {
			  htcta.put(key,ctashast);
			  list.add(ctashast);
		  }
		  catch(Exception e)
		  {
		   System.err.println(e.getMessage()); 
		  }	
		 }//end If 
		 else
		 {
	      itemRemoved = key;			    	       
	     }
 }//End For

 if (!itemRemoved.equals(""))
	  {
	htcta.remove(itemRemoved);
	//response.sendRedirect("../rhplanilla/cta_x_planilla.jsp?change=1&mode="+mode+"&ctaLastLine="+ctaLastLine);
	response.sendRedirect("../rhplanilla/cta_x_planilla.jsp?mode="+mode+"&ctaLastLine="+ctaLastLine);
	return;
	  }	
	 
	 
	 /******************/
	 if (request.getParameter("addCol") != null)
	  {	
	   
		CtaPlanillaDet ctashast= new CtaPlanillaDet();		
		ctashast.setUcta1("0");
		ctashast.setUcta2("0");
		ctashast.setUcta3("0");
		ctashast.setUcta4("0");
		ctashast.setUcta5("0");
		ctashast.setUcta6("0");
		ctashast.setLado("DB");
		ctashast.setConceptoId("0");
		
		++ctaLastLine;
	    if (ctaLastLine < 10) key = "00" + ctaLastLine;
	    else if (ctaLastLine < 100) key = "0" + ctaLastLine;
	    else key = "" + ctaLastLine;
		try
		{ 
		    htcta.put(key, ctashast);
		}
		catch(Exception e)
		{ System.err.println(e.getMessage()); }	 
	//response.sendRedirect("../rhplanilla/cta_x_planilla.jsp?change=1&mode="+mode+"&ctaLastLine="+ctaLastLine);
	response.sendRedirect("../rhplanilla/cta_x_planilla.jsp?mode="+mode+"&ctaLastLine="+ctaLastLine);
	return;
	  }

	CtaPlanilla ctasp= new CtaPlanilla();
	
	ctasp.setPlanillaId(request.getParameter("planillaId"));
	ctasp.setConceptoId(request.getParameter("conceptoId"));
	ctasp.setConceptoIdOld(request.getParameter("conceptoIdOld"));
	if(request.getParameter("unidadAdminId") != null && !request.getParameter("unidadAdminId").trim().equals(""))ctasp.setUnidadAdminId(request.getParameter("unidadAdminId"));
	else ctasp.setUnidadAdminId("null");
	ctasp.setCta1(request.getParameter("cta1"));
	ctasp.setCta2(request.getParameter("cta2")); 
	ctasp.setCta3(request.getParameter("cta3"));
	ctasp.setCta4(request.getParameter("cta4"));
	ctasp.setCta5(request.getParameter("cta5"));
	ctasp.setCta6(request.getParameter("cta6"));
	ctasp.setTipo(request.getParameter("tipo"));   
	ctasp.setLado(request.getParameter("lados"));
	ctasp.setId(request.getParameter("id"));
	ctasp.setUsuarioCreacion((String) session.getAttribute("_userName")); 
	ctasp.setUsuarioModif((String) session.getAttribute("_userName")); 
	ctasp.setCompania((String)session.getAttribute("_companyId"));

	ctasp.setCatalogoCuentas(list);
	ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
	  if (mode.equalsIgnoreCase("add"))
	  { 
		ctasp.setUsuarioCreacion((String) session.getAttribute("_userName")); 
		ctasp.setUsuarioModif((String) session.getAttribute("_userName"));   
		CtaMgr.add(ctasp);
	  }
	  else
	  {
		CtaMgr.updateCta(ctasp);
	  }
	  ConMgr.clearAppCtx(null);
%>
<html>
<head>
<script language="javascript" src="../js/capslock.js"></script>
<script language="javascript">
function closeWindow()
{
  <%if (CtaMgr.getErrCode().equals("1")){%>parent.document.form1.errCode.value = '<%=CtaMgr.getErrCode()%>';
  parent.document.form1.errMsg.value = '<%=CtaMgr.getErrMsg()%>';
  parent.document.form1.submit(); 
  <%} else throw new Exception(CtaMgr.getErrMsg());%>
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>
