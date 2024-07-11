<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="java.util.Vector" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<%@ page import="issi.caja.TransaccionPago"%>
<%@ page import="issi.caja.DetalleBilletes"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="HashBilletes" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="vFacturas" scope="session" class="java.util.Vector" />
<%
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
//if (!(SecMgr.checkAccess(session.getId(),"0")|| SecMgr.checkAccess(session.getId(),"900098")|| SecMgr.checkAccess(session.getId(),"900099")|| SecMgr.checkAccess(session.getId(),"900100"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

SQL2BeanBuilder sbb = new SQL2BeanBuilder();
ArrayList al = new ArrayList();
ArrayList al2 = new ArrayList();
ArrayList lista = new ArrayList();
String mode = request.getParameter("mode");
String key = "";
String sql = "";
int lastLineNo = 0;
int keySize =  0;
int items = 0;

fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);

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
document.title = 'Billetes - '+document.title;
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
<body topmargin="0" leftmargin="0" rightmargin="0" >
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="BILLETES"></jsp:param>
</jsp:include>

<table align="center" width="100%" cellpadding="0" cellspacing="0">
<tr>
<td class="TableBorder">

<table align="center" width="100%" cellpadding="0" cellspacing="1">		
<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
<% if(lastLineNo==0){ lastLineNo=HashBilletes.size(); } %>
<%=fb.formStart(true)%>
<%=fb.hidden("lastLineNo",""+lastLineNo)%>
<%=fb.hidden("keySize",""+HashBilletes.size())%>
<%=fb.hidden("baction","")%>		

<tr class="TextHeader" align="center">
	<td width="50%"><cellbytelabel>Denominaci&oacute;n</cellbytelabel></td>
	<td width="50%"><cellbytelabel>Serie</cellbytelabel></td>
	<td width="3%">
	<%=fb.submit("agregar","+",false,false,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"","Agregar Elemento")%>	</td>
</tr>

<%
al2 = CmnMgr.reverseRecords(HashBilletes);				
for (int i = 1; i <= HashBilletes.size(); i++) {
	items++;
  key = al2.get(i - 1).toString();
  DetalleBilletes dbill = (DetalleBilletes) HashBilletes.get(key);
%>

<%=fb.hidden("key"+i,key)%>
<%=fb.hidden("remove"+i,"")%>

<tr class="TextRow01" align="center">
	<td><%=fb.select("denominacion"+i,"1=1 - UNO,5=5 - CINCO,10=10 - DIEZ,20=20 - VEINTE,50=50 - CINCUENTA, 100=100 - CIEN",dbill.getDenominacion())%></td>
	<td><%=fb.textBox("serie"+i,dbill.getSerie(), false, false,false,10,"Text10","","")%></td>
	<td align="center">
	<%=fb.submit("rem"+i,"X",false,false,null,null,"onClick=\"javascript:removeItem('"+fb.getFormName()+"',"+i+")\"","Eliminar")%>	</td>
</tr>

<%  }  %>
<%=fb.hidden("items",""+items)%>
<tr class="TextRow01">
<td colspan="3" align="right">

	 <%=fb.submit("guardar","Guardar",false,false,"Text10",null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"","Guardar")%>
	 <%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>

</td>
	 </tr>

<%=fb.hidden("size",""+HashBilletes.size())%>
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
else
{


System.out.println("");
System.out.println("");
System.out.println("-------------------------------------------- INICIO POST ----------------------------------------------");
System.out.println("");

		String itemRemoved = "";
		String baction = request.getParameter("baction");
		lastLineNo  = Integer.parseInt(request.getParameter("lastLineNo"));
		keySize = Integer.parseInt(request.getParameter("keySize"));

		System.out.println("");
		System.out.println("baction:"+baction);
		System.out.println("lastLineNo: "+lastLineNo);
		System.out.println("keySize: "+keySize);
		System.out.println("");


//===================== inicio del ciclo FOR ==========================

if (baction.equals("+")){ keySize++; }


for (int i=1; i<=keySize; i++)
{
key = request.getParameter("key"+i);

DetalleBilletes dbill = new DetalleBilletes();
if (request.getParameter("serie"+i) != null) { dbill.setSerie(""+request.getParameter("serie"+i)); } else { dbill.setSerie(""); }
dbill.setDenominacion(""+request.getParameter("denominacion"+i));
dbill.setKey(request.getParameter("key"+i));


System.out.println("");
System.out.println("FOR-> baction: "+baction);
System.out.println("");

				if (request.getParameter("remove"+i) != null && !request.getParameter("remove"+i).equals("")) 
					itemRemoved = dbill.getKey();
				else 
				{
							try
								{ //-- Agregar elemento al Hashtable			
									if (!(baction.equalsIgnoreCase("X"))){ 
									 HashBilletes.put(key, dbill); 
									}
								}
								catch(Exception e){ 
								System.err.println(e.getMessage()); 
								}	
				}

}
//===================== FIN del ciclo FOR =============================


if (baction != null && baction.equals("+"))
{
			DetalleBilletes dbill = new DetalleBilletes();
			lastLineNo++;
			//spl.setSecuencia(""+cLastLineNo);			
			if (lastLineNo < 10) key = "00"+lastLineNo;
			else if (lastLineNo < 100) key = "0"+lastLineNo;
			else key = ""+lastLineNo;
			dbill.setKey(key);

			try
			{
				HashBilletes.put(key, dbill);
			}
			catch(Exception e)
			{
				System.err.println(e.getMessage());
			}
			response.sendRedirect(request.getContextPath()+request.getServletPath()+"?lastLineNo="+lastLineNo);
    	return;
}




	if (!itemRemoved.equals(""))
	{ //-- Elimina elemento del Hashtable
		HashBilletes.remove(itemRemoved);
		System.out.println("=====| (Registro Eliminado): "+itemRemoved);
		System.out.println("");
		response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1");
		return;
	}


//response.sendRedirect(request.getContextPath()+request.getServletPath());




%>
<html>
<head>
<script language="javascript" src="../js/capslock.js"></script>
<script language="javascript">
function closeWindow()
{
window.close();
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>