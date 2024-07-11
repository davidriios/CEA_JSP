<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.convenio.TipoPoliza"%>
<%@ page import="issi.convenio.TipoPlanPoliza"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" 	%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="htplan" scope="session" class="java.util.Hashtable"/>
<jsp:useBean id="TPPMgr" scope="page" class="issi.convenio.TipoPlanPolizaMgr" />
<%
SecMgr.setConnection(ConMgr);
//if (!(SecMgr.checkAccess(session.getId(),"0") || SecMgr.checkAccess(session.getId(),"0") || SecMgr.checkAccess(session.getId(),"0"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);
CmnMgr.setConnection(ConMgr);
//SQLMgr.setConnection(ConMgr);
TPPMgr.setConnection(ConMgr);
//CommonDataObject poliza= new CommonDataObject();
TipoPoliza poliza = new TipoPoliza();
SQL2BeanBuilder sbb = new SQL2BeanBuilder();
String sql="";
String key="";
String id= request.getParameter("id");
String code=request.getParameter("code");
ArrayList al= new ArrayList();
String change= request.getParameter("change");
int planLastLine =0;

if(request.getParameter("planLastLine")!=null && ! request.getParameter("planLastLine").equals(""))
planLastLine=Integer.parseInt(request.getParameter("planLastLine"));

if (request.getMethod().equalsIgnoreCase("GET"))
{
sql = "select codigo, nombre from tbl_adm_tipo_poliza where codigo="+id;
poliza = (TipoPoliza) sbb.getSingleRowBean(ConMgr.getConnection(), sql, TipoPoliza.class);

code="0";
			
if(change==null)
{
		htplan.clear();
		sql = "select a.tipo_plan tipoPlan, a.poliza tipoPoliza, a.nombre, a.comentario,'' estado from tbl_adm_tipo_plan a, tbl_adm_tipo_poliza b where a.poliza= b.codigo and a.poliza="+id;
		al = sbb.getBeanList(ConMgr.getConnection(),sql,TipoPlanPoliza.class);
		System.out.println("SqlDet :: == "+sql);
		//al=SQLMgr.getDataList(sql);
		
			planLastLine=al.size();
			for(int h=0;h<al.size();h++)
			{
				/*planLastLine++;			
				if(planLastLine<10)			
				key="00" + planLastLine;			
				else if(planLastLine<100)			
				key="0" + planLastLine;			
				else 
				key="" + planLastLine;			
				htplan.put(key,al.get(h));*/
			
				TipoPlanPoliza tpp = (TipoPlanPoliza) al.get(h);

				if (h < 10) key = "00"+h;
				else if (h < 100) key = "0"+h;
				else key = ""+h;
				tpp.setKey(key);
	
				try
				{
					htplan.put(key, tpp);
				}
				catch(Exception e)
				{
					System.err.println(e.getMessage());
				}
			}
			if(al.size()==0)
			{
					TipoPlanPoliza tpp =  new TipoPlanPoliza();
					tpp.setTipoPlan("0");
					tpp.setTipoPoliza(id);
		
					planLastLine++;
					if (planLastLine < 10) key = "00" + planLastLine;
					else if (planLastLine < 100) key = "0" + planLastLine;
					else key = "" + planLastLine;
					tpp.setKey(""+key);
			
					try
					{
						htplan.put(key, tpp);
					}
					catch(Exception e)
					{
						System.err.println(e.getMessage());
					}
			
			}
}

%>
<html> 
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp"%>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<script language="javascript">
document.title="Tipo Plan Por Poliza - "+document.title;
function removeItem(fName,k)
{
		var plan = eval('document.form1.code'+k).value;
		var msg='';
		
		if(hasDBData('<%=request.getContextPath()%>','tbl_adm_beneficios_x_admision','tipo_poliza=<%=id%> and tipo_plan='+plan,''))msg+='\n- Beneficios por Admision';
		if(hasDBData('<%=request.getContextPath()%>','tbl_adm_plan_convenio','tipo_poliza=<%=id%> and tipo_plan='+plan,''))msg+='\n- Plan por Convenio'; 
	if(msg=='')
	{
		eval('document.form1.status'+k).value='D';
		var rem = eval('document.'+fName+'.rem'+k).value;
		eval('document.'+fName+'.remove'+k).value = rem;
		setBAction(fName,rem);
		eval('document.form1.baction').value='del';
		document.form1.submit();
	}
	else alert('El plan no se puede eliminar ya que tiene relacionada los siguientes documentos:'+msg);
}

function setBAction(fName,actionValue)
{
	document.forms[fName].baction.value = actionValue;
}
</script>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="TIPO PLAN POR POLIZA"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
	<tr>
		<td class="TableBorder">
			<table align="center" width="99%" cellpadding="0" cellspacing="1">

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
<%fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value!='Guardar')return true;");%>

			<%=fb.formStart(true)%>
			<%=fb.hidden("code",code)%>
			<%=fb.hidden("planLastLine",""+planLastLine)%>
			<%=fb.hidden("keySize",""+htplan.size())%>
			<%=fb.hidden("id",id)%>
			<%=fb.hidden("baction","")%> 
			<tr>
				<td colspan="4">&nbsp;</td>
			</tr>
			<tr class="TextRow02">
				<td colspan="4">&nbsp;</td>
			</tr>	
			<tr class="TextHeader">
				<td colspan="4">&nbsp;<cellbytelabel>Tipos de Poliza</cellbytelabel></td>
			</tr>		
			<tr class="TextRow01">
				<td width="16%">&nbsp;<cellbytelabel>C&oacute;digo</cellbytelabel></td>
				<td width="34%">&nbsp;<%=poliza.getCodigo()%></td>
				<td width="20%">&nbsp;<cellbytelabel>Descripci&oacute;n de la Poliza</cellbytelabel></td>
				<td width="30%">&nbsp;<%=poliza.getNombre()%>
			</tr>		
			<tr class="TextHeader">
				<td colspan="4">&nbsp;<cellbytelabel>Tipos de Plan</cellbytelabel></td>
			</tr>
			<tr>
				<td colspan="4">
					<table width="100%">
						<tr class="TextHeader" align="center">
							<td width="5%"><cellbytelabel>C&oacute;digo</cellbytelabel></td>
							<td width="50%"><cellbytelabel>Nombre</cellbytelabel></td>
							<td width="40%"><cellbytelabel>Observaciones</cellbytelabel></td>
							<td width="5%"><%=fb.submit("agregar","+",true,false,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"","Agregar Plan")%><%//=fb.submit("btnagregar","+",false,false)%></td>
						</tr>
						<%
						String displayLine=""; 						
						 if(htplan.size()>0)
						 al=CmnMgr.reverseRecords(htplan);
						 //for(int i=0; i<htdesc.size();i++)
						 for(int i=0; i<al.size();i++)
							{
								key=al.get(i).toString();
								
								//CommonDataObject cdos=(CommonDataObject) htplan.get(key);
								TipoPlanPoliza tpp = (TipoPlanPoliza) htplan.get(key);
								String color="";								
								if(i%2 == 0) color ="TextRow02";
								else color="TextRow01";
								
								if((tpp.getEstado()!=null && !tpp.getEstado().trim().equals("")) && tpp.getEstado().trim().equals("D"))displayLine="none";
								else displayLine=""; 
							%>
							<%=fb.hidden("key"+i,key)%>
							<%=fb.hidden("remove"+i,"")%>
							<%=fb.hidden("status"+i,tpp.getEstado())%>
						
						<tr class="<%=color%>" style="display:<%=displayLine%>">
							<td align="center">
							<%=fb.intBox("code"+i,tpp.getTipoPlan(),false,false,true,1,3,"Text10",null,null)%>
							</td>
							<td>&nbsp;
							<%=fb.textBox("nombre"+i,tpp.getNombre(),true,false,false,70,100,"Text10",null,null)%>
							</td>
							<td>
							<%=fb.textBox("comentario"+i,tpp.getComentario(),false,false,false,63,2000,"Text10",null,null)%>
							</td>
							<td align="center"><%=fb.button("rem"+i,"X",false,false,null,null,"onClick=\"javascript:removeItem('"+fb.getFormName()+"',"+i+")\"","Eliminar")%></td>
						</tr>
						<%
						}
						%>		
					</table>
				</td>
			</tr>
 			 <tr class="TextRow02">
                   <td align="right" colspan="4"> <cellbytelabel>Opciones de Guardar</cellbytelabel>: 
					<!--<%=fb.radio("saveOption","N")%>Crear Otro --->
					<%=fb.radio("saveOption","O")%>Mantener Abierto 
					<%=fb.radio("saveOption","C",true,false,false)%>Cerrar 
					<%=fb.submit("save","Guardar",true,false,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%>
					<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%> </td>
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
else if(request.getMethod().equalsIgnoreCase("POST"))
{
String saveOption = request.getParameter("saveOption");//N=Create New,O=Keep Open,C=Close
String baction = request.getParameter("baction");

ArrayList list= new ArrayList();
int keySize=Integer.parseInt(request.getParameter("keySize"));
String itemRemoved="",tipoPlan="";
  TipoPoliza tp = new TipoPoliza();
	tp.setCodigo(id);

for(int a=0; a<keySize; a++)
{ 

  CommonDataObject cdo = new CommonDataObject();
  //cdo.setTableName("tbl_adm_tipo_plan");  
  TipoPlanPoliza tpp = new TipoPlanPoliza();
	
	tpp.setTipoPoliza(id);
	tpp.setTipoPlan(request.getParameter("code"+a));
	tpp.setNombre(request.getParameter("nombre"+a));
	tpp.setComentario(request.getParameter("comentario"+a));
	tpp.setEstado(request.getParameter("status"+a));
  //cdo.addColValue("poliza",id);  
  //cdo.addColValue("nombre",request.getParameter("nombre"+a));
  //cdo.addColValue("comentario",request.getParameter("comentario"+a));  
  
	//cdo.addColValue("status",request.getParameter("status"+a));  
	
  key=request.getParameter("key"+a);
	
  if(request.getParameter("remove"+a)!=null && !request.getParameter("remove"+a).equals("") )
	itemRemoved= key;
  //{
	  try
	  {
	  	htplan.put(key,tpp);
	  	//list.add(tpp);
			tp.addTipoPlan(tpp);
	  }
	  catch(Exception e)
	  {
	   System.err.println(e.getMessage()); 
	  }	
  //} 
 // else itemRemoved= key;
 }//End For
 
if(!itemRemoved.equals(""))
{
response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&id="+id+"&planLastLine="+planLastLine);
return;
}
if (baction != null && baction.trim().equalsIgnoreCase("+"))
{
		TipoPlanPoliza tpp = new TipoPlanPoliza();

		tpp.setTipoPlan("0");
		tpp.setTipoPoliza(id);
		
		planLastLine++;
		if (planLastLine < 10) key = "00" + planLastLine;
		else if (planLastLine < 100) key = "0" + planLastLine;
		else key = "" + planLastLine;
		tpp.setKey(""+planLastLine);

		try
		{
			htplan.put(key, tpp);
		}
		catch(Exception e)
		{
			System.err.println(e.getMessage());
		}

response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&id="+id+"&planLastLine="+planLastLine);
 return;
}

if (baction != null && baction.trim().equalsIgnoreCase("Guardar"))
{
	System.out.println("Guardando plan ");
	TPPMgr.savePlan(tp);
	System.out.println("Guardando plan ");
}
%>
<html>
<head>
<script language="javascript" src="../js/capslock.js"></script>
<script language="javascript">
function closeWindow()
{
<%
if (TPPMgr.getErrCode().equals("1"))
{
%>
	alert('<%=TPPMgr.getErrMsg()%>');
<%
	//if (tab.equals("0"))
	//{
		if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/convenio/tipo_plan_list.jsp"))
		{
%>
	window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/convenio/tipo_plan_list.jsp")%>';
<%
		}
		else
		{
%>
	window.opener.location = '<%=request.getContextPath()%>/convenio/tipo_plan_list.jsp';
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
} else throw new Exception(TPPMgr.getErrMsg());
%>
}

function addMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>';
}

function editMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?id=<%=id%>';
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>
