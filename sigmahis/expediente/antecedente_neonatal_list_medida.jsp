<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.Vector" %>
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
<jsp:useBean id="mFactor" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="vFactor" scope="session" class="java.util.Vector" />

<%
/**
==================================================================================
0				SYSTEM ADMINISTRATOR
==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
//if (!(SecMgr.checkAccess(session.getId(),"0") || SecMgr.checkAccess(session.getId(),"100007") || SecMgr.checkAccess(session.getId(),"100008") || SecMgr.checkAccess(session.getId(),"100013"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
CommonDataObject cdo = new CommonDataObject();
String sql = "";
String mode = request.getParameter("mode");
String id = request.getParameter("id");
String key = "";
String change = request.getParameter("change");
String factor = request.getParameter("factor");
int mFLastLineNo = 0;

if (mode == null) mode = "add";
if (request.getParameter("mFLastLineNo") != null) mFLastLineNo = Integer.parseInt(request.getParameter("mFLastLineNo"));

if (request.getMethod().equalsIgnoreCase("GET"))
{
	if (mode.equalsIgnoreCase("add"))
	{
		id = "0";
		mFactor.clear();
		vFactor.clear();
	}
	else
	{
	  if (id == null) throw new Exception("El factor no es válido. Por favor intente nuevamente!");
	    
	if (change == null)
	{
		  mFactor.clear();
			vFactor.clear();
		sql = " SELECT a.cod_factor,a.cod_medida, a.comentario , b.descripcion  from tbl_sal_umed_x_factor_neo a , tbl_inv_unidad_medida b where a.cod_factor="+id+" and a.cod_medida=b.cod_medida order by cod_factor";
		
				al  = SQLMgr.getDataList(sql);
				mFLastLineNo = al.size();
				
				for (int i=0; i<al.size(); i++)
					{
						  cdo = (CommonDataObject) al.get(i);
							if (i < 10) key = "00" + i;
							else if (i < 100) key = "0" + i;
							else key = "" + i;
							cdo.addColValue("key",key);
		
						try
						{
							mFactor.put(key, cdo);
							vFactor.addElement(cdo.getColValue("cod_medida"));
						}
						catch(Exception e)
						{
							System.err.println(e.getMessage());
						}
				}
	
	   }
		
		}//else
%>
<html>   
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/tab.jsp" %>
<script language="javascript">
document.title = 'UNIDADES DE MEDIDA DEL FACTOR NEONATAL - '+document.title;
 function showlistmedida()
 {
abrir_ventana1('../common/check_unidad_medida.jsp?fp=listFactor&mode=<%=mode%>&id=<%=id%>&mFLastLineNo=<%=mFLastLineNo%>');

}
function showMedidaFactor()
{
  abrir_ventana1('../expediente/antecedente_neonatal_list.jsp');
}
function removeItem(fName,k)
{
	var rem = eval('document.'+fName+'.rem'+k).value;
	eval('document.'+fName+'.remove'+k).value = rem;
	setBAction(fName,rem);
}
</script>

</head>
<body topmargin="0" leftmargin="0" rightmargin="0" bgcolor="#fafbfa">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="EXPEDIENTE FACTOR NEONATAL-UNIDAD DE MEDIDAS"></jsp:param>
</jsp:include>

<table align="center" width="99%" cellpadding="5" cellspacing="0">
<tr>
	<td class="TableBorder">
		<table align="center" width="100%" cellpadding="1" cellspacing="1">
	<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("id",id)%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("Factorsize",""+mFactor.size())%>
<%=fb.hidden("mFLastLineNo",""+mFLastLineNo)%>
				<tr class="TextRow02">
					<td>&nbsp;</td>
				</tr>
				<tr >
					<td onClick="javascript:showHide(0)" style="text-decoration:none; cursor:pointer">
						<table width="100%" cellpadding="0" cellspacing="1">
						<tr class="TextPanel">
							<td width="95%">&nbsp;<cellbytelabel id="1">Factor neonatal</cellbytelabel></td>
							<td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus0" style="display:none">+</label><label id="minus0">-</label></font>]&nbsp;</td>
						</tr>
						
						
						</table>
					</td>
				</tr>
			
					<tr class="TextRow01" id="panel0">
							<td>  
								 <table width="100%" cellpadding="0" cellspacing="0">
										<tr class="TextRow01">
											<td>
											<cellbytelabel id="2">C&oacute;digo</cellbytelabel>
											<%=id%></td>
																			
										</tr>
								</table>  
							</td>		 
					</tr>	
				<tr  >
					<td onClick="javascript:showHide(1)" style="text-decoration:none; cursor:pointer">
						<table width="100%" cellpadding="0" cellspacing="0">
						   <tr class="TextPanel">
											<td width="95%">&nbsp;<cellbytelabel id="3">Unidades de medida del factor neonatal</cellbytelabel></td>
											<td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus1" style="display:none">+</label><label id="minus1">-</label></font>]&nbsp;</td>
						   </tr>
						</table>
					</td>
				</tr>	
				<tr >
							<td id="panel1">	
									<table width="100%" cellpadding="1" cellspacing="0">
										<tr class="TextHeader" align="center">
														<td width="10%"><cellbytelabel id="2">C&oacute;digo</cellbytelabel></td>
														<td width="20%"><cellbytelabel id="4">Unidad de Medida</cellbytelabel></td>
														<td width="65%"><cellbytelabel id="5">Comentario</cellbytelabel></td>
														<td width="5%"><%=fb.button("addMedida","+",true,false,null,null,"onClick=\"javascript:showlistmedida()\"","Agregar Unidad de Medida")%></td>
										</tr>
<%

al = CmnMgr.reverseRecords(mFactor);	
for (int i=0; i<mFactor.size(); i++)
{
  key = al.get(i).toString();		
  cdo = (CommonDataObject) mFactor.get(key);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
%>

					<%=fb.hidden("descripcion"+i,cdo.getColValue("descripcion"))%>
					<%=fb.hidden("cod_medida"+i,cdo.getColValue("cod_medida"))%>
					<%=fb.hidden("key"+i,key)%>
					<%=fb.hidden("remove"+i,"")%>
					<tr class="<%=color%>" align="center">
										<td><%=cdo.getColValue("cod_medida")%></td>
										<td><%=cdo.getColValue("descripcion")%></td>
										<td><%=fb.textBox("comentario"+i,cdo.getColValue("comentario"),false,false,false,90,500,null,"width:100%","")%></td>
										<td align="center"><%=fb.submit("rem"+i,"X",true,false,null,null,"onClick=\"javascript:removeItem('"+fb.getFormName()+"',"+i+")\"","Eliminar unidad de medida")%></td>
						
						</tr>
<%   
}
%>				</table>  
			</td>
		</tr>
			<tr class="TextRow02">
					<td colspan="4" align="right">
						<cellbytelabel id="6">Opciones de Guardar</cellbytelabel>: 
						<!--<%//=fb.radio("saveOption","N")%>Crear Otro -->
						
						<%=fb.radio("saveOption","O")%><cellbytelabel id="7">Mantener Abierto</cellbytelabel> 
						<%=fb.radio("saveOption","C",true,false,false)%><cellbytelabel id="8">Cerrar</cellbytelabel> 
						<%=fb.submit("save","Guardar",true,false)%>
						<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
					</td>
			</tr>
<%=fb.formEnd(true)%>
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
	String saveOption = request.getParameter("saveOption");//N=Create New,O=Keep Open,C=Close
	String baction = request.getParameter("baction");
	int size = 0;
		if (request.getParameter("Factorsize") != null) 
		size = Integer.parseInt(request.getParameter("Factorsize"));
		String itemRemoved = "";
		al.clear();
		for (int i=0; i<size; i++)
		{
			cdo = new CommonDataObject();
			cdo.setTableName("tbl_sal_umed_x_factor_neo");  
			cdo.setWhereClause("cod_factor="+id+"");
			cdo.addColValue("cod_factor",request.getParameter("id"));
			cdo.addColValue("cod_medida",request.getParameter("cod_medida"+i));
			cdo.addColValue("comentario",request.getParameter("comentario"+i));
			cdo.addColValue("descripcion",request.getParameter("descripcion"+i));
			cdo.addColValue("key",request.getParameter("key"+i));
			key=request.getParameter("key"+i);
			
			if (request.getParameter("remove"+i) != null && !request.getParameter("remove"+i).equals("")) 
				itemRemoved = cdo.getColValue("key");  
			else
			{
			
				try
				{
					al.add(cdo);
					mFactor.put(key,cdo);
					
				}
				catch(Exception e)
				{
					System.err.println(e.getMessage());
				}
			}//End else
		}//end For

if(!itemRemoved.equals(""))
{
	mFactor.remove(itemRemoved);
	response.sendRedirect(request.getContextPath()+request.getServletPath()+"?fp=listFactor&change=1&mode="+mode+"&id="+id+"&mFLastLineNo="+mFLastLineNo);
	return;
}
if (al.size() == 0)
{
		cdo = new CommonDataObject();
		cdo.setTableName("tbl_sal_umed_x_factor_neo");  
		cdo.setWhereClause("cod_factor="+id+"");
		al.add(cdo); 
}
SQLMgr.insertList(al);
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
//	if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/admin/centro_servicio_list.jsp"))
//	{
%>
//	window.opener.location = '<%//=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/admin/centro_servicio_list.jsp")%>';
<%
//	}
//	else
//	{
%>
//	window.opener.location = '<%//=request.getContextPath()%>/admin/centro_servicio_list.jsp';
<%
//	}

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
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?fp=listFactor&mode=edit&id=<%=id%>';
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>