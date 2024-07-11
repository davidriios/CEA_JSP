
<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="java.util.Vector"%>
<%@ page import="java.util.ResourceBundle" %>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="htinsumo" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="htuso" scope="session" class="java.util.Hashtable"/>
<jsp:useBean id="htequipo" scope="session" class="java.util.Hashtable"/>
<jsp:useBean id="vctarticulo" scope="session" class="java.util.Vector" />
<jsp:useBean id="vctuso" scope="session" class="java.util.Vector"/>
<%
/**
==================================================================================
==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
//if (!(SecMgr.checkAccess(session.getId(),"0") || SecMgr.checkAccess(session.getId(),"0") || SecMgr.checkAccess(session.getId(),"0"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);
CommonDataObject malet= new CommonDataObject();
ArrayList al= new ArrayList();
String key ="";
String sql ="";
String tab = request.getParameter("tab");
String mode =request.getParameter("mode");
String id =request.getParameter("id");
String change = request.getParameter("change");
String appendFilter = "";
//String date= CmnMgr.getCurrentDate("dd/mm/yyyy hh24:mi:ss");
int insuLastLineNo = 0;
int equipLastLineNo = 0;
int usoLastLineNo = 0;

if(tab == null)  tab = "0";
if(mode == null) mode ="add";

if(request.getParameter("insuLastLineNo") != null)
insuLastLineNo = Integer.parseInt(request.getParameter("insuLastLineNo"));

if(request.getParameter("equipLastLineNo") != null)
equipLastLineNo = Integer.parseInt(request.getParameter("equipLastLineNo"));

if(request.getParameter("usoLastLineNo") != null)
usoLastLineNo = Integer.parseInt(request.getParameter("usoLastLineNo"));

if (request.getMethod().equalsIgnoreCase("GET"))
{
//fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);
	if (mode.equalsIgnoreCase("add"))
	{
	id = "0";
	htinsumo.clear();
    htuso.clear();
	htequipo.clear();
	vctarticulo.clear();
	vctuso.clear();
	}
	else
	{
		if (id == null) throw new Exception("El Maletín no es válido. Por favor intente nuevamente!");
		
/*Modo edit de maletin*/
sql="select codigo, descripcion, observacion, usuario_modificacion, fecha_modificacion from tbl_cds_maletin where codigo="+id;	malet = SQLMgr.getData(sql);

 	if(change== null)
	{
	/*Query de maletin de insumo*/
	
	/*String almacenSOP = ResourceBundle.getBundle("issi").getString("almacenSOP");*/
	/*appendFilter +=" and i.codigo_almacen="+almacenSOP;*/
	String almacenSOP = "1";
	appendFilter +=" and i.codigo_almacen="+almacenSOP;
	System.out.println("change="+change);
	sql = "select  a.cod_familia||'-'||a.cod_clase||'-'||a.cod_articulo as codigos, a.cod_maletin as maletin, a.compania, a.cod_familia, a.cod_clase, a.cod_articulo, a.cantidad, a.observacion, a.usuario_modificacion, a.fecha_modificacion , e.cod_flia as familia, e.cod_clase as clase, e.cod_articulo, e.descripcion, b.cod_flia as codeflia, b.cod_clase as codeclase, b.descripcion as nom, c.cod_flia as codefamilia, c.nombre, to_char( nvl(e.precio_venta,0), '9,999999.99' ) precio_venta, (select to_char(nvl(precio,0), '9,999999.99') from tbl_inv_inventario where codigo_almacen = (select min(codigo_almacen) from tbl_inv_inventario  where compania = e.compania and cod_articulo =e.cod_articulo) and compania = e.compania and cod_articulo = e.cod_articulo ) costo from tbl_cds_maletin_insumo a, tbl_inv_articulo e, tbl_inv_clase_articulo b, tbl_inv_familia_articulo c where e.cod_flia=b.cod_flia and e.cod_clase= b.cod_clase and e.cod_flia= c.cod_flia and e.compania =b.compania and e.compania=c.compania and a.cod_familia=e.cod_flia and a.cod_familia=b.cod_flia and  a.cod_familia=c.cod_flia and a.cod_clase=e.cod_clase and a.cod_clase=b.cod_clase  and a.cod_articulo=e.cod_articulo and a.compania=e.compania and a.compania=b.compania and a.compania=c.compania and a.compania="+(String) session.getAttribute("_companyId")+" and a.cod_maletin="+id+"  order by e.descripcion ";
al = SQLMgr.getDataList(sql);

htinsumo.clear();
htuso.clear();
htequipo.clear();
vctarticulo.clear();
vctuso.clear();
	
insuLastLineNo= al.size();

for (int i=1; i<=al.size(); i++)
{
	CommonDataObject cdo = (CommonDataObject) al.get(i-1);
	
	if (i < 10) key = "00" + i;
	else if (i < 100) key = "0" + i;
	else key = "" + i;
	cdo.addColValue("key",key);
	
	try
	{
		htinsumo.put(key, cdo);
		vctarticulo.addElement(cdo.getColValue("codigos"));
	}
	catch(Exception e)
	{
		System.err.println(e.getMessage());
	}
}  	//End For
/*Query de uso de maletines*/
sql = "select a.cod_maletin as maleta, a.cod_uso, a.observacion, a.usuario_modificacion,a.fecha_modificacion, b.codigo as ot,  b.descripcion as nametarifa, c.codigo, c.descripcion as descripciones from tbl_cds_maletin_activo a, tbl_sal_uso b, tbl_cds_maletin c where a.cod_uso=b.codigo and a.compania=  b.compania  and a.cod_maletin= c.codigo and a.compania="+(String) session.getAttribute("_companyId")+" and a.cod_maletin="+id+"  order by b.descripcion";
al = SQLMgr.getDataList(sql);

usoLastLineNo =  al.size();

for (int i = 1; i <= al.size(); i++)
{
CommonDataObject cdo = (CommonDataObject) al.get(i-1);
		if( i <10)
		key = "00" + i;
		else if(i < 100)
		key ="0"+ i;
		else key = "" +i;
		cdo.addColValue("key",key);
		try 
		{
		htuso.put(key,cdo);
		
		vctuso.addElement(cdo.getColValue("cod_uso"));
		}
		catch(Exception e)
		{
		System.err.println(e.getMessage());
		}
}// end for
	
/*Query de equipo de maletines*/
sql = "select a.cod_maletin as maletin, a.codigo, a.descripcion, a.fecha_modificacion, a.fecha_modificacion,b.codigo as ot, b.descripcion as nom, b.observacion  from tbl_cds_maletin_equipo a,tbl_cds_maletin b where a.cod_maletin=b.codigo and  a.cod_maletin="+id;
al = SQLMgr.getDataList(sql);	

equipLastLineNo = al.size();	

for (int i=0; i <al.size(); i++)
{
equipLastLineNo++;
	
	if (equipLastLineNo < 10) key = "00" + equipLastLineNo;
	else if (equipLastLineNo < 100) key = "0" + equipLastLineNo;
	else key = "" + equipLastLineNo;
	
	//try
	//{
		htequipo.put(key, al.get(i));
	//}
	//catch(Exception e)
	//{
		//System.err.println(e.getMessage());
	//}
} //End For


	}//if change
	
}//edit

%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/tab.jsp" %>
<script language="javascript">
document.title = 'Maletín - Edición - '+document.title;

function removeItem(fName,k)
{
	var rem = eval('document.'+fName+'.rem'+k).value;
	eval('document.'+fName+'.remove'+k).value = rem;
	setBAction(fName,rem);
}

function setBAction(fName,actionValue)
{
	document.forms[fName].baction.value = actionValue;
}

function articulos()
{
abrir_ventana3('../inventario/list_articulo.jsp?mode=<%=mode%>&id=<%=id%>&insuLastLineNo=<%=insuLastLineNo%>&usoLastLineNo=<%=usoLastLineNo%>&equipLastLineNo=<%=equipLastLineNo%>');
}

function tarifa()
{
abrir_ventana3('../inventario/list_sal_uso.jsp?mode=<%=mode%>&id=<%=id%>&insuLastLineNo=<%=insuLastLineNo%>&usoLastLineNo=<%=usoLastLineNo%>&equipLastLineNo=<%=equipLastLineNo%>');
}

</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<jsp:include page="../common/title.jsp" flush="true">
<jsp:param name="title" value="INVENTARIO - MANTENIMIENTO - MALETÍN"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
  <tr>
    <td class="TableBorder"><table align="center" width="100%" cellpadding="5" cellspacing="0">
        <tr>
          <td><!--Inicio de  los Tab-->
            <div id="dhtmlgoodies_tabView1">
              <!--Inicio de Tab0 Generales del Maletín-->
              <div class="dhtmlgoodies_aTab">
                <table align="center" width="100%" cellpadding="0" cellspacing="1">
                  <!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
                  <%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
                  <%=fb.formStart(true)%> 
				  <%=fb.hidden("tab","0")%> 
				  <%=fb.hidden("mode",mode)%> 
				  <%=fb.hidden("id",id)%> 
				  <%=fb.hidden("baction","")%> 
				  <%=fb.hidden("insumoSize",""+htinsumo.size())%> 
				  <%=fb.hidden("insuLastLineNo",""+insuLastLineNo)%> 
				  <%=fb.hidden("usoSize",""+htuso.size())%> 
				  <%=fb.hidden("usoLastLineNo",""+usoLastLineNo)%> 
				  <%=fb.hidden("equipoSize",""+htequipo.size())%> 
				  <%=fb.hidden("equipLastLineNo",""+equipLastLineNo)%>
                  <tr class="TextRow02">
                    <td>&nbsp;</td>
                  </tr>
                  <tr>
                    <td onClick="javascript:showHide(0)" style="text-decoration:none; cursor:pointer"><table width="100%" cellpadding="1" cellspacing="0">
                        <tr class="TextHeader">
                          <td width="95%">&nbsp;Generales de Malet&iacute;n</td>
                          <td width="5%" align="right">[<font face="Courier New, Courier, mono">
                            <label id="plus0" style="display:none">+</label>
                            </font>]&nbsp;</td>
                        </tr>
                      </table></td>
                  </tr>
                  <tr id="panel0">
                    <td><table width="100%" cellpadding="1" cellspacing="1">
                        <tr class="TextRow01">
                          <td width="16%">&nbsp;C&oacute;digo</td>
                          <td width="84%"><%=id%></td>
                        </tr>
                        <tr class="TextRow01">
                          <td>&nbsp;Descripci&oacute;n</td>
                          <td><%=fb.textBox("descripcion",malet.getColValue("descripcion"),false,false,false,55,200)%></td>
                        </tr>
                        <tr class="TextRow01">
                          <td>&nbsp;Observaci&oacute;n</td>
                          <td><%=fb.textBox("observacion",malet.getColValue("observacion"),false,false,false,55,200)%></td>
                        </tr>
                      </table></td>
                  </tr>
                  <tr>
                    <td><jsp:include page="../common/bitacora.jsp" flush="true">
                      <jsp:param name="audTable" value="tbl_cds_maletin"></jsp:param>
                      <jsp:param name="audFilter" value="<%="codigo="+id%>"></jsp:param>
                      </jsp:include>
                    </td>
                  </tr>
                  <tr class="TextRow02">
                    <td align="right"> Opciones de Guardar: <%=fb.radio("saveOption","N")%>Crear Otro <%=fb.radio("saveOption","O",true,false,false)%>Mantener Abierto <%=fb.radio("saveOption","C",false,false,false)%>Cerrar <%=fb.submit("save","Guardar",true,false)%> <%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%> </td>
                  </tr>
                  <%=fb.formEnd(true)%>
                </table>
              </div>
              <!--Fin de Tab0  Generales de Maletin-->
              <!-- Inicio de Tab1 Insumo de Maletin-->
              <div class="dhtmlgoodies_aTab">
                <table width="100%" cellpadding="0" cellspacing="1">
                  <%fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
                  <%=fb.formStart(true)%> 
				  <%=fb.hidden("tab","1")%> 
				  <%=fb.hidden("mode",mode)%> 
				  <%=fb.hidden("id",id)%> 
				  <%=fb.hidden("baction","")%> 
				  <%=fb.hidden("insumoSize",""+htinsumo.size())%> 
				  <%=fb.hidden("insuLastLineNo",""+insuLastLineNo)%> 
				  <%=fb.hidden("usoSize",""+htuso.size())%> 
				  <%=fb.hidden("usoLastLineNo",""+usoLastLineNo)%> 
				  <%=fb.hidden("equipoSize",""+htequipo.size())%> 
				  <%=fb.hidden("equipLastLineNo",""+equipLastLineNo)%>
                  <tr class="TextRow02">
                    <td>&nbsp;</td>
                  </tr>
                  <tr>
                    <td onClick="javascript:showHide(10)" style="text-decoration:none; cursor:pointer"><table width="100%" cellpadding="1" cellspacing="0">
                        <tr class="TextHeader">
                          <td width="95%">&nbsp;Malet&iacute;n</td>
                          <td width="5%" align="right">[<font face="Courier New, Courier, mono">
                            <label id="plus10" style="display:none">+</label>
                            <label id="nimus10">-</label>
                            </font>]&nbsp;</td>
                        </tr>
                      </table></td>
                  </tr>
                  <tr id="panel10">
                    <td><table width="100%" cellpadding="1" cellspacing="1">
                        <tr class="TextRow01">
                          <td width="16%">&nbsp;C&oacute;digo</td>
                          <td width="84%"><%=malet.getColValue("codigo")%></td>
                        </tr>
                        <tr class="TextRow01">
                          <td>&nbsp;Descripci&oacute;n</td>
                          <td><%=malet.getColValue("descripcion")%></td>
                        </tr>
                      </table></td>
                  </tr>
                  <tr>
                    <td onClick="javascript:showHide(11)" style="text-decoration:none; cursor:pointer"><table width="100%" cellpadding="1" cellspacing="0">
                        <tr class="TextHeader">
                          <td width="95%">&nbsp;Insumo de Malet&iacute;n</td>
                          <td width="5%" align="right">[<font face="Courier New, Courier, mono">
                            <label id="plus11" style="display:none">+</label>
                            <label id="minus11">-</label>
                            </font>]&nbsp;</td>
                        </tr>
                      </table></td>
                  </tr>
                  <tr id="panel11">
                    <td><table width="100%" cellpadding="1" cellspacing="1">
                        <tr class="TextHeader" align="center">
                          <td width="12%" align="center">&nbsp;C&oacute;digo de Articulos</td>
                          <td width="27%">&nbsp;Descripci&oacute;n</td>
                          <td width="25%">&nbsp;Observaci&oacute;n</td>
                          <td width="10%">&nbsp;Precio</td>
                          <td width="10%">&nbsp;Costo</td>
                          <td width="8%" align="center">Cantidad</td>
                          <td width="8%">&nbsp;<%=fb.button("agregar","+",true,false,null,null,"onClick=\"javascript:articulos()\"","Agregar Articulos")%></td>
                        </tr>
                        <%
			al=CmnMgr.reverseRecords(htinsumo);
			for(int a =1; a <=htinsumo.size();a++)
			{
			key=al.get(a-1).toString();
			CommonDataObject cdos= (CommonDataObject) htinsumo.get(key);		
			%>
                        <%=fb.hidden("key"+a,cdos.getColValue("key"))%> 
						<%=fb.hidden("cod_familia"+a,cdos.getColValue("cod_familia"))%> 
						<%=fb.hidden("cod_clase"+a,cdos.getColValue("cod_clase"))%> 
						<%=fb.hidden("cod_articulo"+a,cdos.getColValue("cod_articulo"))%> 
						<%=fb.hidden("codigos"+a,cdos.getColValue("codigos"))%> 
						<%=fb.hidden("descripcion"+a,cdos.getColValue("descripcion"))%> 
						<%=fb.hidden("remove"+a,"")%>
                        <tr class="TextRow01">
                          <td>&nbsp;<%=cdos.getColValue("codigos")%></td>
                          <td>&nbsp;<%=cdos.getColValue("descripcion")%></td>
                          <td><%=fb.textBox("observacion"+a,cdos.getColValue("observacion"),false,false,false,43,200,"Text10",null,null)%></td>
                          <td align="center"><b><%=cdos.getColValue("precio_venta")%></b></td>
			  <td align="center"><b><%=cdos.getColValue("costo")%></b></td>
                          <td align="center"><%=fb.decBox("cantidad"+a,cdos.getColValue("cantidad"),false,false,false,5,4,"Text10",null,null)%></td>
                          <td align="center"><%=fb.submit("rem"+a,"X",true,false,null,null,"onClick=\"javascript:removeItem('"+fb.getFormName()+"',"+a+")\"","Eliminar")%> </td>
                        </tr>
                        <%
			}
			%>
                      </table></td>
                  </tr>
                  <tr class="TextRow02">
                    <td align="right" colspan="2"> 
					Opciones de Guardar: 
					<%=fb.radio("saveOption","N")%>Crear Otro 
					<%=fb.radio("saveOption","O",true,false,false)%>Mantener Abierto 
					<%=fb.radio("saveOption","C",false,false,false)%>Cerrar 
					<%=fb.submit("save","Guardar",true,false,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%> 
					<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%> </td>
                  </tr>
                  <%=fb.formEnd(true)%>
                </table>
              </div>
              <!--Fin de Tab1 Insumo de Maletin-->
              <!--Inicio de Tab2 Uso de Maletín-->
              <div class="dhtmlgoodies_aTab">
                <table width="100%" align="center" cellpadding="0" cellspacing="1">
                  <%fb = new FormBean("form2",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
                  <%=fb.formStart(true)%> 
				  <%=fb.hidden("tab","2")%> 
				  <%=fb.hidden("mode",mode)%> 
				  <%=fb.hidden("id",id)%> 
				  <%=fb.hidden("baction","")%> 
				  <%=fb.hidden("insumoSize",""+htinsumo.size())%> 
				  <%=fb.hidden("insuLastLineNo",""+insuLastLineNo)%> 
				  <%=fb.hidden("usoSize",""+htuso.size())%> 
				  <%=fb.hidden("usoLastLineNo",""+usoLastLineNo)%> 
				  <%=fb.hidden("equipoSize",""+htequipo.size())%> 
				  <%=fb.hidden("equipLastLineNo",""+equipLastLineNo)%>
                  <tr class="TextRow02">
                    <td>&nbsp;</td>
                  </tr>
                  <TR>
                    <td onClick="javascript:showHide(20)" style="text-decoration:none; cursor:pointer"><table width="100%" cellpadding="1" cellspacing="0">
                        <tr class="TextHeader">
                          <td width="95%">&nbsp;Malet&iacute;n</td>
                          <td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus11" style="display:none">+</label><label id="minus11">-</label></font>]&nbsp;</td>
                        </tr>
                      </table></td>
                  </TR>
                  <tr id="panel20">
                    <td><table width="100%" cellpadding="1" cellspacing="1">
                        <tr class="TextRow01">
                          <td width="16%">&nbsp;C&oacute;digo</td>
                          <td width="84%"><%=malet.getColValue("codigo")%></td>
                        </tr>
                        <tr class="TextRow01">
                          <td>&nbsp;Descripci&oacute;n</td>
                          <td><%=malet.getColValue("descripcion")%></td>
                        </tr>
                      </table></td>
                  </tr>
                  <tr>
                    <td onClick="javascript:showHide(21)" style="text-decoration:none; cursor:pointer"><table width="100%" cellpadding="1" cellspacing="0">
                        <tr class="TextHeader">
                          <td width="95%">&nbsp;Uso de Malet&iacute;n</td>
                          <td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus11" style="display:none">+</label><label id="minus11">-</label></font>]&nbsp;</td>
                        </tr>
                      </table></td>
                  </tr>
                  <tr id="panel21">
                    <td><table width="100%" cellpadding="1" cellspacing="1">
                        <tr class="TextHeader">
                          <td width="10%">&nbsp;C&oacute;digo</td>
                          <td width="50%">&nbsp;Descripci&oacute;n</td>
                          <td width="35%">&nbsp;Observaciones</td>
                          <td width="5%">&nbsp;<%=fb.button("agregar","+",true,false,null,null,"onClick=\"javascript:tarifa()\"","Agregar Tarifa")%></td>
                        </tr>
                        <%
			al=CmnMgr.reverseRecords(htuso);
			for(int a =1; a <=htuso.size();a++)
			{
				key=al.get(a-1).toString();
				CommonDataObject igdy= (CommonDataObject) htuso.get(key);
			%>
                        <tr class="TextRow01"> 
						<%=fb.hidden("key"+a,igdy.getColValue("key"))%> 
						<%=fb.hidden("cod_uso"+a,igdy.getColValue("cod_uso"))%> 
						<%=fb.hidden("nametarifa"+a,igdy.getColValue("nametarifa"))%> 
						<%=fb.hidden("remove"+a,"")%>
                          <td>&nbsp;<%=igdy.getColValue("cod_uso")%></td>
                          <td>&nbsp;<%=igdy.getColValue("nametarifa")%> </td>
                          <td><%=fb.textBox("observacion"+a,igdy.getColValue("observacion"),false,false,false,40,2000,"Text10",null,null)%> </td>
                          <td align="center"><%=fb.submit("rem"+a,"X",true,false,null,null,"onClick=\"javascript:removeItem('"+fb.getFormName()+"',"+a+")\"","Eliminar")%></td>
                        </tr>
                        <%
			}
			%>
                      </table></td>
                  </tr>
                  <tr class="TextRow02">
                    <td align="right"> Opciones de Guardar: 
					<%=fb.radio("saveOption","N")%>Crear Otro 
					<%=fb.radio("saveOption","O",true,false,false)%>Mantener Abierto <%=fb.radio("saveOption","C",false,false,false)%>Cerrar 
					<%=fb.submit("save","Guardar",true,false,null,null,"onClick=\"javascript:removeItem('"+fb.getFormName()+"',this.value)\"")%> <%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%> </td>
                  </tr>
                  <%=fb.formEnd(true)%>
                </table>
              </div>
              <!--Fin de Tab2 Uso de Maletin -->
              <!--Inicio de Tab3 Equipo de Maletin-->
              <div class="dhtmlgoodies_aTab">
                <table width="100%" align="center" cellpadding="0" cellspacing="1">
                  <%fb = new FormBean("form3",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
                  <%=fb.formStart(true)%> 
				  <%=fb.hidden("tab","3")%> 
				  <%=fb.hidden("mode",mode)%> 
				  <%=fb.hidden("id",id)%> 
				  <%=fb.hidden("baction","")%> 
				  <%=fb.hidden("insumoSize",""+htinsumo.size())%> 
				  <%=fb.hidden("insuLastLineNo",""+insuLastLineNo)%> 
				  <%=fb.hidden("usoSize",""+htuso.size())%> 
				  <%=fb.hidden("usoLastLineNo",""+usoLastLineNo)%> 
				  <%=fb.hidden("equipoSize",""+htequipo.size())%> 
				  <%=fb.hidden("equipLastLineNo",""+equipLastLineNo)%>				  
                  <tr class="TextRow02">
                    <td>&nbsp;</td>
                  </tr>
                  <tr>
                    <td onClick="javascript:showHide(30)" style="text-decoration:none; cursor:pointer"><table width="100%" cellpadding="1" cellspacing="0">
                        <tr class="TextHeader">
                          <td width="95%">&nbsp;Malet&iacute;n</td>
                          <td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus30" style="display:none">+</label><label id="minus30">-</label></font>]&nbsp;</td>
                        </tr>
                      </table></td>
                  </tr>
                  <tr id="panel30">
                    <td><table width="100%" cellpadding="1" cellspacing="1">
                        <tr class="TextRow01">
                          <td width="16%">&nbsp;C&oacute;digo</td>
                          <td width="84%"><%=malet.getColValue("codigo")%></td>
                        </tr>
                        <tr class="TextRow01">
                          <td>&nbsp;Descripci&oacute;n</td>
                          <td><%=malet.getColValue("descripcion")%></td>
                        </tr>
                      </table></td>
                  </tr>
                  <tr>
                    <td onClick="javascript:showHide(31)" style="text-decoration:none; cursor:pointer"><table width="100%" cellpadding="1" cellspacing="0">
                        <tr class="TextPanel">
                          <td width="95%">&nbsp;Equipo de Malet&iacute;n</td>
                          <td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus31" style="display:none">+</label><label id="minus31">-</label></font>]&nbsp;</td>
                        </tr>
                      </table></td>
                  </tr>
                  <tr id="panel31">
                    <td><table width="100%" cellpadding="0" cellspacing="1">
                        <tr class="TextHeader">
                          <td width="20%" align="center">Codigo</td>
                          <td width="70%" align="center">Descripci&oacute;n</td>
                          <td width="10%">&nbsp;<%=fb.submit("btnagregar","+",false,false)%></td>
                        </tr>
						<tr>
                        <%
						String code="0";
						//if(htequipo.size()>0)
						al=CmnMgr.reverseRecords(htequipo);
						for(int a=0;a<htequipo.size();a++)
						{ 					
						key = al.get(a).toString();
						CommonDataObject cdos= (CommonDataObject) htequipo.get(key);		
						%>                       
                        <tr class="TextRow01">
						<%=fb.hidden("key"+a,key)%> 
                          <td>
						  <%=fb.intBox("code"+a,cdos.getColValue("codigo"),false,false,true,2,3,"Text10",null,null)%></td>
                          <td><%=fb.textBox("descripcion"+a,cdos.getColValue("descripcion"),false,false,false,85,500,"Text10",null,null)%></td>
                          <td align="center"><%=fb.submit("remover"+a,"X",false,false)%></td>
                        </tr>
                        <%
						}
						%>
                      </table></td>
                  </tr>
                  <tr class="TextRow02">
                    <td align="right"> Opciones de Guardar: <%=fb.radio("saveOption","N")%>Crear Otro 
					<%=fb.radio("saveOption","O",true,false,false)%>Mantener Abierto 
					<%=fb.radio("saveOption","C",false,false,false)%>Cerrar
					<%=fb.submit("save","Guardar",true,false)%>                  
					<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%> </td>
                  </tr>
                  <%=fb.formEnd(true)%>
                </table>
              </div>
              <!--Fin Tab3 Equipo de Maletin-->
              <!--MAIN DIV END HERE-->
            </div>
            <script type="text/javascript">
<%
if(mode.equalsIgnoreCase("add"))
{
%>
initTabs('dhtmlgoodies_tabView1',Array('Maletín'),0,'100%','');
<%
}
else 
{
%>
initTabs('dhtmlgoodies_tabView1',Array('Maletín','Insumo','Uso','Equipo'),<%=tab%>,'100%','');
<%
}
%>
</script>
          </td>
        </tr>
      </table></td>
  </tr>
</table>
<jsp:include page="../common/footer.jsp" flush="true"></jsp:include>
</body>
</html>
<%
}//GET 
else
{

String saveOption = request.getParameter("saveOption");//N=Create New,O=Keep Open,C=Close
String baction = request.getParameter("baction");

if(tab.equals("0")) //Tab General de Maletin
{
 malet= new CommonDataObject();
 
  malet.setTableName("tbl_cds_maletin");
  malet.addColValue("descripcion",request.getParameter("descripcion")); 	
  malet.addColValue("observacion",request.getParameter("observacion"));
  malet.addColValue("usuario_modificacion",(String) session.getAttribute("_userName"));//UserDet.getUserEmpId()
  malet.addColValue("fecha_modificacion",CmnMgr.getCurrentDate("dd/mm/yyyy hh24:mi:ss"));
  
  if (mode.equalsIgnoreCase("add"))
  {
	malet.addColValue("usuario_creacion",(String) session.getAttribute("_userName"));//UserDet.getUserEmpId()
  	malet.addColValue("fecha_creacion",CmnMgr.getCurrentDate("dd/mm/yyyy hh24:mi:ss"));	
	malet.setAutoIncCol("codigo");
	malet.addPkColValue("codigo","");
	SQLMgr.insert(malet);
	id = SQLMgr.getPkColValue("codigo");
  }
  else
  {
    malet.setWhereClause("codigo="+request.getParameter("id"));

	SQLMgr.update(malet);
  }
}  
else if(tab.equals("1"))//INSUMO
{

int size=0;
if(request.getParameter("insumoSize") != null)
size = Integer.parseInt(request.getParameter("insumoSize"));
String itemRemoved = "";
al.clear();
for(int i=1; i<= size; i++)
{
 CommonDataObject cdo= new CommonDataObject();
  cdo.setTableName("tbl_cds_maletin_insumo");  
  cdo.setWhereClause("cod_maletin="+id);
  cdo.addColValue("cod_maletin",id);  
  cdo.addColValue("cod_familia",request.getParameter("cod_familia"+i));
  cdo.addColValue("cod_clase",request.getParameter("cod_clase"+i));
  cdo.addColValue("cod_articulo",request.getParameter("cod_articulo"+i));
  cdo.addColValue("codigos",request.getParameter("codigos"+i));
  cdo.addColValue("descripcion",request.getParameter("descripcion"+i));
  cdo.addColValue("observacion",request.getParameter("observacion"+i));
  cdo.addColValue("cantidad",request.getParameter("cantidad"+i)); 
  cdo.addColValue("compania",(String) session.getAttribute("_companyId"));
  cdo.addColValue("fecha_modificacion",CmnMgr.getCurrentDate("dd/mm/yyyy hh24:mi:ss"));
  cdo.addColValue("usuario_modificacion",(String) session.getAttribute("_userName"));
  cdo.addColValue("fecha_creacion",CmnMgr.getCurrentDate("dd/mm/yyyy hh24:mi:ss"));
  cdo.addColValue("usuario_creacion",(String) session.getAttribute("_userName")); 
  cdo.addColValue("key",request.getParameter("key"+i));
  
  if(request.getParameter("remove"+i) !=  null && !request.getParameter("remove"+i).equals(""))
   itemRemoved= cdo.getColValue("key");
 
  else
  {
  	try
	{
		htinsumo.put(cdo.getColValue("key"),cdo);
		al.add(cdo);
		
	}
	catch(Exception e)
	{
		System.err.println(e.getMessage());
	}
  }
}//End for
if(!itemRemoved.equals(""))
{

vctarticulo.remove(((CommonDataObject)htinsumo.get(itemRemoved)).getColValue("codigos"));
htinsumo.remove(itemRemoved);
response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&tab=1&mode="+mode+"&id="+id+"&insuLastLineNo="+insuLastLineNo+"&usoLastLineNo="+usoLastLineNo+"&equipLastLineNo="+equipLastLineNo);
return;
}//end if

if(al.size() == 0)
{ 
  CommonDataObject cdo = new CommonDataObject();
  cdo.setTableName("tbl_cds_maletin_insumo");  
  cdo.setWhereClause("cod_maletin="+id);
  al.add(cdo);
  
}//end if

SQLMgr.insertList(al);
}  

else if(tab.equals("2"))	 // Uso
{

int size=0;
if(request.getParameter("usoSize")	!= null)
size = Integer.parseInt(request.getParameter("usoSize"));
String itemRemoved = "";
al.clear();
for(int i=1; i<=size; i++)
{System.out.println("+++++Size++++++++="+size);

 CommonDataObject cdo= new CommonDataObject();
	cdo.setTableName("tbl_cds_maletin_activo");  
	cdo.setWhereClause("cod_maletin="+id);
	cdo.addColValue("cod_maletin",id); 
	cdo.addColValue("cod_uso",request.getParameter("cod_uso"+i));
	cdo.addColValue("nametarifa",request.getParameter("nametarifa"+i));
	cdo.addColValue("observacion",request.getParameter("observacion"+i));
	cdo.addColValue("usuario_modificacion",(String) session.getAttribute("_userName"));
	cdo.addColValue("fecha_modificacion",CmnMgr.getCurrentDate("dd/mm/yyyy hh24:mi:ss"));
	cdo.addColValue("compania",(String) session.getAttribute("_companyId"));
	cdo.addColValue("fecha_creacion",CmnMgr.getCurrentDate("dd/mm/yyyy hh24:mi:ss"));
	cdo.addColValue("usuario_creacion",(String) session.getAttribute("_userName"));
	cdo.addColValue("key",request.getParameter("key"+i));
	
	if(request.getParameter("remove"+i) != null && !request.getParameter("remove"+i).equals(""))
	itemRemoved=cdo.getColValue("key");
	
	else
	{
		try
		{
		System.out.println("++++++++cargas el hashtable="+cdo.getColValue("key"));
		htuso.put(cdo.getColValue("key"),cdo);
		al.add(cdo);
		}
		catch(Exception e)
		{
			System.err.println(e.getMessage());
		}
	}
}//End For

if(!itemRemoved.equals(""))
{
System.out.println("++++++opcion de eliminar="+itemRemoved);
vctuso.remove(((CommonDataObject)htuso.get(itemRemoved)).getColValue("cod_uso"));
htuso.remove(itemRemoved);
System.out.println("***************************************AFTER itemRemoved"); 
response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&tab=2&mode="+mode+"&id="+id+"&insuLastLineNo="+insuLastLineNo+"&usoLastLineNo="+usoLastLineNo+"&equipLastLineNo="+equipLastLineNo);
return;
}//end if
if(al.size() == 0)
{
 CommonDataObject cdo = new CommonDataObject();
  cdo.setTableName("tbl_cds_maletin_activo");  
  cdo.setWhereClause("cod_maletin="+id); 
  al.add(cdo);
}//enf if

SQLMgr.insertList(al);

}//end if tab

 else if(tab.equals("3")) //equipo
 {
 ArrayList list = new ArrayList();
//int size=0;
//if(request.getParameter("equipoSize")!= null) 
 int equipoSize = Integer.parseInt(request.getParameter("equipoSize"));
 String itemRemoved = "";
 //al.clear();
 for(int i=0; i<equipoSize; i++)
 {
 	CommonDataObject cdo = new CommonDataObject();
	cdo.setTableName("tbl_cds_maletin_equipo");	
	cdo.setWhereClause("cod_maletin="+id);
	cdo.addColValue("cod_maletin",id);	
	cdo.addColValue("descripcion",request.getParameter("descripcion"+i));
	cdo.addColValue("usuario_creacion",(String) session.getAttribute("_userName"));
	cdo.addColValue("fecha_creacion", CmnMgr.getCurrentDate("dd/mm/yyyy hh24:mi:ss"));
	cdo.addColValue("fecha_modificacion",CmnMgr.getCurrentDate("dd/mm/yyyy hh24:mi:ss"));
	cdo.addColValue("usuario_modificacion",(String) session.getAttribute("_userName"));
	cdo.addColValue("codigo",request.getParameter("code"+i));
	cdo.setAutoIncWhereClause("cod_maletin="+request.getParameter("id"));
	cdo.setAutoIncCol("codigo");
	key=request.getParameter("key"+i);
	//cdo.addColValue("key",request.getParameter("key"+i));

	if(request.getParameter("remover"+i) == null)
	{	try
		{
		htequipo.put(key,cdo);
		list.add(cdo);
		}
		catch(Exception e)
		{
			System.err.println(e.getMessage());
		}
	}else itemRemoved= key;
 }//End For
 
 
if(!itemRemoved.equals(""))
{
	htequipo.remove(key);
	response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&tab=3&mode="+mode+"&id="+id+"&insuLastLineNo="+insuLastLineNo+"&usoLastLineNo="+usoLastLineNo+"&equipLastLineNo="+equipLastLineNo);
	return;
}//end if

System.out.println("++++++agregar+++++++++="+request.getParameter("btnagregar"));
if(request.getParameter("btnagregar")!=null)//Agregar
{
	CommonDataObject cdo = new CommonDataObject();	
	cdo.addColValue("cod_maletin","0");
	cdo.addColValue("codigo","0");
	equipLastLineNo++;
	if (equipLastLineNo < 10) key = "00" + equipLastLineNo;
	else if (equipLastLineNo < 100) key = "0" + equipLastLineNo;
	else key = "" + equipLastLineNo;
	htequipo.put(key,cdo);
	response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&tab=3&mode="+mode+"&id="+id+"&insuLastLineNo="+insuLastLineNo+"&usoLastLineNo="+usoLastLineNo+"&equipLastLineNo="+equipLastLineNo);
	return;
}

SQLMgr.insertList(list);

 }//End Tab
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
	if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/inventario/maletin_list.jsp"))
	{
%>
	window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/inventario/maletin_list.jsp")%>';
<%
	}
	else
	{
%>
	window.opener.location = '<%=request.getContextPath()%>/inventario/maletin_list.jsp';
<%
	}

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
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?mode=edit&tab=<%=tab%>&id=<%=id%>';
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>
