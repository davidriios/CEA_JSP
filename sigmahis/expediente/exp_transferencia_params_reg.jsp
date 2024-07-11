<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Hashtable"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" %>

<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="iParams" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="vParams" scope="session" class="java.util.Vector" />
<%
/**
==================================================================================
==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
CommonDataObject cdo = new CommonDataObject();

boolean viewMode = false;
String sql = "", appendFilter = "";
String mode = request.getParameter("mode");
String tipo = request.getParameter("tipo")==null?"":request.getParameter("tipo");
String tipoDesc = request.getParameter("tipoDesc")==null?"":request.getParameter("tipoDesc");
String company = (String)session.getAttribute("_companyId");

if (tipo.trim().equals("")) throw new Exception("El tipo es inválido. Por favor contacte un administrador!");

if (mode == null) mode = "add";
if (!tipo.equals("")) appendFilter += " and tipo = "+tipo+"";

String tab = request.getParameter("tab");
String change = request.getParameter("change");
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String key = "";

if (request.getMethod().equalsIgnoreCase("GET"))
{

if(change == null)
{
	iParams.clear();
    vParams.clear();

	sql="select tipo, decode(tipo,1,'CONDICION DEL PACIENTE EN EL MOMENTO DE TRASLADO',2,'REQUERIMIENTO DEL TRASLADO',3,'MOTIVO DEL TRASLADO',4,'DOCUMENTOS') as tipo_desc, status, decode(status,'A','Activo','I','Inactivo') as status_desc, descripcion, id, es_otro from  tbl_sal_transferencia_params where compania = "+company+appendFilter+" order by id"; 
	
	al = SQLMgr.getDataList(sql);
	for (int i=0; i<al.size(); i++)
	{
		cdo = (CommonDataObject) al.get(i);
		cdo.setKey(i);
		cdo.setAction("U");

		try
		{
			iParams.put(cdo.getKey(),cdo);
            vParams.addElement(cdo.getColValue("id")+"-"+company);
		}
		catch(Exception e)
		{
			System.err.println(e.getMessage());
		}
	}
	
	if (al.size() == 0)
	{
		cdo = new CommonDataObject();
		cdo.addColValue("id","0");

		cdo.setKey(iParams.size()+1);
		cdo.setAction("I");

		try
		{
			iParams.put(cdo.getKey(),cdo);
            vParams.addElement(cdo.getColValue("id"));
		}
		catch(Exception e)
		{
			System.err.println(e.getMessage());
		}
	}

}//change
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript">
document.title = 'EXPEDIENTE - PARAMETROS TRANSFERENCIA '+document.title;
function doAction(){}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<jsp:include page="../common/title.jsp"  flush="true">
	<jsp:param name="title" value="EXPEDIENTE - MANTENIMIENTO"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
	<tr>
		<td>
				<table width="100%" cellpadding="1" cellspacing="1" >
					 <%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
					 <%=fb.formStart(true)%>
					 <%fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value!='Guardar')return true;");%>
					 <%=fb.hidden("baction","")%>
					 <%=fb.hidden("mode",mode)%>
					 <%=fb.hidden("pSize",""+iParams.size())%>
					 <%=fb.hidden("tipo",tipo)%>
					 <%=fb.hidden("tipoDesc",tipoDesc)%>
					 <%=fb.hidden("compania",company)%>

					<tr class="TextHeader" >
						<td colspan="6"><cellbytelabel><%=tipoDesc%></cellbytelabel></td>
					</tr>
					<tr class="TextHeader">
						<td width="10%" class="Text10" align="center"><cellbytelabel>ID</cellbytelabel></td>
						<td width="30%" class="Text10" align="center"><cellbytelabel>TIPO</cellbytelabel></td>
						<td width="46%" class="Text10"><cellbytelabel>DESCRIPCION</cellbytelabel></td>
                        <td>
                            OTRO?
                        </td>
						<td width="10%" class="Text10" align="center"><cellbytelabel>ESTADO</cellbytelabel></td>
						<td width="4%">
                        <%=fb.submit("agregar","+",true,viewMode,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"","Agregar Parámetros")%>
						</td>
					</tr>
					
				<%
				al.clear();
				al = CmnMgr.reverseRecords(iParams);

				for (int i = 0; i <iParams.size(); i++)
				{
				String color = "TextRow01";
				if (i % 2 == 0) color = "TextRow02";

			    key = al.get(i).toString();
				cdo = (CommonDataObject) iParams.get(key);
				%>
					<tr class="<%=color%>" id="row<%=i%>">
                    <%=fb.hidden("remove"+i,"")%>
					 <%=fb.hidden("action"+i,cdo.getAction())%>
					 <%=fb.hidden("key"+i,cdo.getKey())%>
						<td align="center"><%=fb.textBox("id"+i,cdo.getColValue("id")==null?"0":cdo.getColValue("id"),true,false,true,10,10,"Text10",null,"")%></td>
						<td>
						<%if(!tipo.trim().equals("") && !tipo.trim().equals("0")){%>
						<%=fb.hidden("tipo"+i,tipo)%>
						<%=tipoDesc%>
						<%}else{%>
						<%=fb.select("tipo"+i,"1=CONDICION DEL PACIENTE EN EL MOMENTO DE TRASLADO,2=REQUERIMIENTO DEL TRASLADO,3=MOTIVO DEL TRASLADO,4=DOCUMENTOS",cdo.getColValue("tipo"),false,false,0,"","width:320px","onClick=")%>
						<%}%>
						</td>
						<td><%=fb.textBox("descripcion"+i,cdo.getColValue("descripcion"),true,false,viewMode,100,1000,"Text10",null,null)%></td>
                        <td align="center"><%=fb.select("es_otro"+i,"N=NO,Y=SI",cdo.getColValue("es_otro"),false,false,0,"","","")%></td>
						<td><%=fb.select("status"+i,"A=ACTIVO,I=INACTIVO",cdo.getColValue("status"),false,false,0,"","","")%></td>
						<td>
						<%=fb.button("remove"+i,"X",true, true ,null,null,"onClick=setAction('X',"+i+")","Eliminar")%>
						</td>
					</tr>
					
				<%}%>
				
				
				<tr class="TextRow02">
					<td colspan="6" align="right">
				<cellbytelabel id="6">Opciones de Guardar</cellbytelabel>:
				<%=fb.radio("saveOption","O",true,viewMode,false)%><cellbytelabel>Mantener Abierto</cellbytelabel>
				<%=fb.radio("saveOption","C",false,viewMode,false)%><cellbytelabel>Cerrar</cellbytelabel>
                <%=fb.submit("save","Guardar",true,viewMode,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%>
				<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=window.close()")%>
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
	String saveOption = request.getParameter("saveOption");
	String baction = request.getParameter("baction");
	String itemRemoved = "", lastRemCode = "";
 	
	int size = 0;
	al.clear();
	iParams.clear();
    vParams.clear();
    
	if (request.getParameter("pSize") != null) size = Integer.parseInt(request.getParameter("pSize"));

	for (int i=0; i<size; i++)
	{
		CommonDataObject cdo2 = new CommonDataObject();
		cdo2.setTableName("tbl_sal_transferencia_params");
		cdo2.setWhereClause("tipo="+request.getParameter("tipo"+i)+" and compania ="+request.getParameter("compania")+" and id="+request.getParameter("id"+i));
		
		cdo2.addColValue("tipo",request.getParameter("tipo"+i));
		cdo2.addColValue("status",request.getParameter("status"+i));
		cdo2.addColValue("descripcion",request.getParameter("descripcion"+i));
		cdo2.addColValue("es_otro",request.getParameter("es_otro"+i));
		cdo2.addColValue("compania",request.getParameter("compania"));
					
		if (request.getParameter("id"+i)==null || ( request.getParameter("id"+i).trim().equals("0")||request.getParameter("id"+i).trim().equals("")))
		{
			cdo2.setAutoIncCol("id");
			cdo2.setAutoIncWhereClause("compania="+request.getParameter("compania"));
		}else cdo2.addColValue("id",request.getParameter("id"+i));
			cdo2.setAction(request.getParameter("action"+i).trim()==null||request.getParameter("action"+i).trim().equals("")?"I":request.getParameter("action"+i));
			cdo2.setKey(i);
	  
	 	if (request.getParameter("remove"+i) != null && !request.getParameter("remove"+i).equals(""))
		{
			itemRemoved = cdo2.getKey();
            lastRemCode = cdo2.getColValue("id") + "-" + company;
			if (cdo2.getAction().equalsIgnoreCase("I")) cdo2.setAction("X");//if it is not in DB then remove it
			else cdo2.setAction("D");
		}
	
		if (!cdo2.getAction().equalsIgnoreCase("X"))
		{
			try
			{
				iParams.put(cdo2.getKey(),cdo2);
                vParams.addElement(cdo2.getColValue("id") +"-"+ company);
				al.add(cdo2);
			}
			catch(Exception e)
			{
				System.err.println(e.getMessage());
			}
		}
	}//for
	
	if(!itemRemoved.equals(""))
	{
        vParams.remove(lastRemCode);
        response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&mode="+mode+"&tipo="+request.getParameter("tipo")+"&tipoDesc="+request.getParameter("tipoDesc"));
		return;
	}
	if(baction.equals("+")) //Agregar
	{
		CommonDataObject cdo2 = new CommonDataObject();

		cdo2.addColValue("id","0");
		cdo2.setAction("I");
		cdo2.setKey(iParams.size()+1);

		try
		{
			iParams.put(cdo2.getKey(),cdo2);
		}
		catch(Exception e)
		{
			System.err.println(e.getMessage());
		}
		response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&mode="+mode+"&tipo="+request.getParameter("tipo")+"&tipoDesc="+request.getParameter("tipoDesc"));
		return;
	}
		
	if (baction.equalsIgnoreCase("Guardar"))
	{
		if (al.size() == 0)
		{
			CommonDataObject cdo3 = new CommonDataObject();

			cdo3.setTableName("tbl_sal_transferencia_params");
			cdo3.setWhereClause("tipo="+request.getParameter("tipo")+" and compania ="+request.getParameter("compania")+" and id="+request.getParameter("id"));
			cdo3.setAction("I");
			al.add(cdo3);
		}

		SQLMgr.saveList(al,true);
	}
%>
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
	window.opener.location = "../expediente/exp_transferencia_params_list.jsp";
<%
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
} else throw new Exception(SQLMgr.getErrMsg());
%>
}
function addMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>';
}
function editMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?tipo=<%=tipo%>&codigo=&mode=<%=mode%>&tipoDesc=<%=tipoDesc%>';
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>
