<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.Enumeration" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Vector" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="java.util.StringTokenizer"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.CommonDataObject"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="htDet" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="htDesc" scope="page" class="java.util.Hashtable" />
<jsp:useBean id="htPA" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="vDet" scope="session" class="java.util.Vector" />
<jsp:useBean id="vDesc" scope="page" class="java.util.Vector" />
<jsp:useBean id="vDescuento" scope="session" class="java.util.Vector" />
<%
	SQLMgr.setConnection(ConMgr);

	String mode=request.getParameter("mode");
	String change=request.getParameter("change");
	String id = request.getParameter("id");
	String fp = request.getParameter("fp");
	String fg = request.getParameter("fg");
	String profUpd = request.getParameter("profUpd");
	String key = "";
	
	String show_desc 					= request.getParameter("show_desc");
	String del 								= request.getParameter("del");
	String codigo 						= request.getParameter("codigo");
	String descripcion 				= request.getParameter("descripcion");
	String id_precio 					= request.getParameter("id_precio");
	String precio 						= request.getParameter("precio");
	String precio_ejecutivo		= request.getParameter("precio_ejecutivo");
	String precio_colaborador	= request.getParameter("precio_colaborador");
	String precio_normal			= request.getParameter("precio_normal");
	String cantidad 					= request.getParameter("cantidad");
	String itbm 							= request.getParameter("itbm");
	String tipo_art 					= request.getParameter("tipo_art");
	String tipo_articulo			= request.getParameter("tipo_articulo");
	String adding 						= request.getParameter("adding");
	String codigo_almacen 		= request.getParameter("codigo_almacen");
	String precio_app 				= request.getParameter("precio_app");
	String val_desc 				= request.getParameter("val_desc");
	String tipo_desc 				= request.getParameter("tipo_desc");
	String change_precio 				= request.getParameter("change_precio");
	
	String gravable_perc 			= request.getParameter("gravable_perc"); 
	String total 							= request.getParameter("total"); 
	String total_desc 				= request.getParameter("total_desc"); 
	String id_descuento 			= request.getParameter("id_descuento"); 
	String tipo_descuento			= request.getParameter("tipo_descuento"); 
	String tipo_servicio			= request.getParameter("tipo_servicio"); 
	String refer_to						= request.getParameter("refer_to");
	String afecta_inventario	= request.getParameter("afecta_inventario");
	String costo							= request.getParameter("costo");
	String cod_barra					= request.getParameter("cod_barra");
	String qty_ini						= request.getParameter("qty_ini");
	String keypad						= request.getParameter("use_keypad") == null ? "" : request.getParameter("use_keypad");
	String touch						= request.getParameter("touch") == null ? "" : request.getParameter("touch");
	codigo = tipo_articulo+"@"+codigo; 
	//System.out.println("codigo="+codigo);
	////System.out.println("costo="+costo);
	////System.out.println("precio="+precio);
	////System.out.println("qty_ini="+qty_ini);
	////System.out.println("adding="+adding);
	ArrayList al = new ArrayList();
  
  boolean useKeypad = keypad.trim().equals("true");
	
	CommonDataObject cdo = new CommonDataObject();
	if(del==null) del = "";
	if(show_desc==null) show_desc = "";
	if(adding==null) adding = "add";
	////System.out.println("cantidad="+cantidad);
	if(codigo==null) codigo = "";
	if(descripcion==null) descripcion = "";
	if(id_precio==null) id_precio = "0";
	if(precio==null) precio = "0";
	if(precio_ejecutivo==null) precio_ejecutivo = "0";
	if(precio_colaborador==null) precio_colaborador = "0";
	if(precio_normal==null) precio_normal = "0";
	if(cantidad==null) cantidad = "0";
	if(itbm==null) itbm = "N";
	if(tipo_art==null) tipo_art = "N";
	if(tipo_articulo==null) tipo_articulo = "";
	if(codigo_almacen==null) codigo_almacen = "";
	if(total_desc==null) total_desc = "";
	if(id_descuento==null) id_descuento = "";
	if(tipo_descuento==null) tipo_descuento = "";
	if(change_precio==null) change_precio = "N";
System.out.println("----------------------------------------------------------------------------------------->itbm="+itbm+" gravable_perc="+gravable_perc);
	if(gravable_perc==null && itbm.equals("S")) { double d = Double.parseDouble((String) session.getAttribute("_taxPercent")); gravable_perc = ""+(d / 100); }
System.out.println("----------------------------------------------------------------------------------------->itbm="+itbm+" gravable_perc="+gravable_perc);
	if(gravable_perc==null) gravable_perc = "0";
	if(tipo_servicio==null) tipo_servicio = "0";
	if(costo==null) costo = "0";
	if(refer_to==null) refer_to = "";
	if(precio_app==null) precio_app = "N";
	if(afecta_inventario==null) afecta_inventario = "N";
	if(cod_barra==null) cod_barra = "";
	if(val_desc==null) val_desc = "";
	if(tipo_desc==null) tipo_desc = "";
	if(qty_ini==null) qty_ini = "0";	
	if(profUpd==null) profUpd = "S";
	
	cdo.addColValue("codigo", codigo);
	cdo.addColValue("descripcion", descripcion);
	cdo.addColValue("id_precio", id_precio);
	cdo.addColValue("precio", precio);
	cdo.addColValue("precio_normal", precio_normal);
	cdo.addColValue("cantidad", cantidad);
	cdo.addColValue("itbm", itbm);
	cdo.addColValue("tipo_art", tipo_art);
	cdo.addColValue("tipo_articulo", tipo_articulo);
	cdo.addColValue("codigo_almacen", codigo_almacen);
	cdo.addColValue("total_desc", total_desc);
	cdo.addColValue("id_descuento", id_descuento);
	cdo.addColValue("tipo_descuento", tipo_descuento);
	cdo.addColValue("gravable_perc", gravable_perc);
	cdo.addColValue("tipo_servicio", tipo_servicio);
	cdo.addColValue("refer_to", refer_to);
	cdo.addColValue("precio_app", precio_app);
	cdo.addColValue("afecta_inventario", afecta_inventario);
	cdo.addColValue("costo", costo);
	cdo.addColValue("cod_barra", cod_barra);
	cdo.addColValue("qty_ini", qty_ini);
	cdo.addColValue("val_desc", val_desc);
	cdo.addColValue("tipo_desc", tipo_desc);
	if(cdo.getColValue("id_precio").equals("3") && tipo_articulo.equals("C") && cdo.getColValue("precio_app").equals("S")){
		if(!htPA.contains(codigo)){
			//System.out.println("adding item pa............."+codigo);
			htPA.put(codigo, cdo);
			cdo.addColValue("precio_app", "S");
		} else {
			cdo.addColValue("precio", cdo.getColValue("precio_normal"));
			cdo.addColValue("id_precio", "1");
			cdo.addColValue("precio_app", "N");
		}
	}

	int lineNo = 0;
	if(!del.equals("")){
		//System.out.println("deleting..."+del);
		if(del.equals("all")){
			htDet.clear();
			htPA.clear();
			htDesc.clear();
			vDesc.clear();
			vDescuento.clear();
			vDet.clear();
		}	
		Hashtable htCopy = (Hashtable) htDet.clone();
		if (htDet.size() != 0) al = CmnMgr.reverseRecords(htDet);
		htDet.clear();
		htDesc.clear();
		htPA.clear();
		vDet.clear();
		vDesc.clear();
		vDescuento.clear();
		for(int i=0; i<htCopy.size();i++){
			key = al.get(i).toString();
			CommonDataObject cdx = (CommonDataObject) htCopy.get(key);
			String _codigo = codigo.replace("N@","").replace("I@","").replace("C@","");
			//System.out.println("......_codigo="+_codigo+",......codigo="+codigo+",......cdx.codigo="+cdx.getColValue("codigo"));
			//if(!cdx.getColValue("codigo").equals(_codigo) && !cdx.getColValue("codigo").replace("@D@","").equals(codigo))
			if(!cdx.getColValue("codigo").equals(codigo) && !cdx.getColValue("codigo").equals(codigo+"@D@")){
				lineNo++;
				String newKey = "";
				if (lineNo < 10) newKey = "00"+lineNo;
				else if (lineNo < 100) newKey = "0"+lineNo;
				else newKey = ""+lineNo;
				try{
					htDet.put(newKey,cdx);
					vDet.addElement(cdx.getColValue("codigo"));
					//System.out.println("adding item cdx...==============="+cdx.getColValue("codigo"));
				} catch (Exception e){
					//System.out.println("Unable to add item...");
				}
			}
		}
		htCopy.clear();
	} else {
		System.out.println("validacion de descuento vDet.contains="+vDet.contains(codigo.replace("@D@","")));
		if(vDet.contains(codigo.replace("@D@",""))){
			if (htDet.size() != 0) al = CmnMgr.reverseRecords(htDet, false);
			for (int i=0; i<htDet.size(); i++){
				key = al.get(i).toString();
				CommonDataObject cd = (CommonDataObject) htDet.get(key);
				if(cd.getColValue("codigo").equals(codigo) || cd.getColValue("codigo").equals(codigo.replace("@D@",""))){
					if(codigo.contains("@D@")){
						if(key.contains("-")){
						} else {								
							double _key = Double.parseDouble(key)-0.1;
							if (_key < 10) key = "00"+_key;
							else if (_key < 100) key = "0"+_key;
							else key = ""+_key;
						}
						System.out.println("total: "+total);
						if(!cdo.getColValue("descripcion").contains("DESC. ")) cdo.addColValue("descripcion", "DESC. "+cdo.getColValue("descripcion"));
						if(total!=null) cdo.addColValue("total", total);
						else cdo.addColValue("total", ""+(Integer.parseInt(cdo.getColValue("cantidad"))*Double.parseDouble(cdo.getColValue("precio"))));
						if(!vDescuento.contains(codigo)) htDet.put(key, cdo);
						//System.out.println("codigo dentro del for de descuento: "+cdo.getColValue("codigo"));
					} else {
						System.out.println(".............................................:jose ");
						cdo.addColValue("cantidad", ""+(adding.equals("reem")?Integer.parseInt(cantidad):(Integer.parseInt(cd.getColValue("cantidad"))+(adding.equals("add")?1:-1))));
						System.out.println("...................total="+total);
						System.out.println("...................change_precio="+change_precio);
						cdo.addColValue("total", ""+(Integer.parseInt(cdo.getColValue("cantidad"))*Double.parseDouble((change_precio.equals("S")?cdo.getColValue("precio"):cd.getColValue("precio")))));
						if(cdo.getColValue("cantidad").equals("0")){
							htDet.remove(key);
							vDet.remove(codigo);
						} else htDet.put(key, cdo);
					}
					break;
				}
			}
		} else if(!codigo.contains("@D@")){
			////System.out.println(".............................................: ");
			cdo.addColValue("total", ""+(Integer.parseInt(cdo.getColValue("cantidad"))*Double.parseDouble(cdo.getColValue("precio"))));
			System.out.println("total....="+cdo.getColValue("total"));
			lineNo = htDet.size();
			lineNo++;
			if (lineNo < 10) key = "00"+lineNo;
			else if (lineNo < 100) key = "0"+lineNo;
			else key = ""+lineNo;

			try{
				htDet.put(key,cdo);
				vDet.addElement(codigo);
				////System.out.println("adding item...key "+key+", codigo "+cdo.getColValue("codigo"));
				//System.out.println("adding item...vDet codigo "+codigo);
			} catch (Exception e){
				//System.out.println("Unable to add item...");
			}
		}
	}
	if (htDet.size() != 0) al = CmnMgr.reverseRecords(htDet, false);
	for (int i=0; i<htDet.size(); i++){
		key = al.get(i).toString();
		CommonDataObject cd = (CommonDataObject) htDet.get(key);
		//System.out.println("codigo htDet..."+cd.getColValue("codigo")+", tipo_articulo="+cd.getColValue("tipo_articulo")+", codigo="+cdo.getColValue("codigo"));
		if(cd.getColValue("codigo").contains("@D@")){ 
			/*
			if(cd.getColValue("codigo").indexOf(cdo.getColValue("tipo_articulo")+"@")==-1) vDesc.addElement(cdo.getColValue("tipo_articulo")+"@"+cd.getColValue("codigo").replace("@D@",""));
			else*/

			vDesc.addElement(cd.getColValue("codigo").replace("@D@",""));
			vDescuento.addElement(cd.getColValue("codigo"));
			htDesc.put(cd.getColValue("codigo"), cd);
			System.out.println("codigo Descuento.................."+cd.getColValue("codigo"));
		}
	}
	
	
	
	////System.out.println("codigo..............................................................."+cdo.getColValue("codigo"));
	////System.out.println("htDesc.size()="+htDesc.size());
	if(mode==null) mode="add";
	if(fp==null) fp="";
	if(fg==null) fg="";
	if (request.getMethod().equalsIgnoreCase("GET")){
%>
<div width="95%" align="right">
	<%if(show_desc.equals("S")){%><a href="javascript:chkDesc('J');" class="btn btn-xs btn-danger">Desc. Jubilado</a>&nbsp;<a href="javascript:chkDesc('E');" class="btn btn-xs btn-success">Desc. Empleado</a><%}%>
</div>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
<tr>
	<td class="TableBorder">
		<table align="center" width="100%" cellpadding="1" cellspacing="1">
			<%fb = new FormBean("articles",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
			<%=fb.formStart(true)%>
			<tr class="TextHeader" align="center">
				<td width="55%">Art&iacute;culo</td>
				<td width="7%">&nbsp;</td>
				<td width="10%">Cant.</td>
				<td width="15%">P/U</td>
				<td width="10%">Total</td>
				<td width="3%">
				<%if(profUpd.trim().equals("S")){%><input type="button" class="btn btn-sm btn-danger" id="rem" name="rem" value="X" onClick="javascript:borrarAll();"><%}%></td>
			</tr>
			<%
			if (htDet.size() > 0) al = CmnMgr.reverseRecords(htDet, false);
			String height = "27", width="27",codigoSinSymb="";
			for (int i=0; i<htDet.size(); i++){
				key = al.get(i).toString();
				cdo = new CommonDataObject();
				cdo = (CommonDataObject) htDet.get(key);
				String color = "";
				if (i%2 == 0) color = "TextRow02";
				else color = "TextRow01";
				double total_itbm = (/*!cdo.getColValue("tipo_art").equals("D") && */cdo.getColValue("itbm").equals("S")?(Double.parseDouble(cdo.getColValue("cantidad"))*Double.parseDouble(cdo.getColValue("precio"))*Double.parseDouble(cdo.getColValue("gravable_perc"))):0.00);
				codigoSinSymb=cdo.getColValue("codigo").replace("N@","").replace("I@","").replace("C@","");
			%>
			<%=fb.hidden("codigo_concat"+i,cdo.getColValue("codigo"))%>
			<%=fb.hidden("codigo"+i,codigoSinSymb)%>
			<%=fb.hidden("descripcion"+i,cdo.getColValue("descripcion"))%>
			<%=fb.hidden("precio"+i,cdo.getColValue("precio"))%>
			<%=fb.hidden("precio_app"+i,""+cdo.getColValue("precio_app"))%>
			<%=fb.hidden("precio_normal"+i,""+cdo.getColValue("precio_normal"))%>
			<%=fb.hidden("id_precio"+i,""+cdo.getColValue("id_precio"))%>
			<%=fb.hidden("codigo_almacen"+i,cdo.getColValue("codigo_almacen"))%>
			<%=fb.hidden("id_descuento"+i,cdo.getColValue("id_descuento"))%>
			<%=fb.hidden("tipo_descuento"+i,cdo.getColValue("tipo_descuento"))%>
			<%=fb.hidden("total_desc"+i,cdo.getColValue("total_desc"))%>
			<%=fb.hidden("gravable_perc"+i,cdo.getColValue("gravable_perc"))%>
			<%=fb.hidden("itbm"+i,cdo.getColValue("itbm"))%>
			<%=fb.hidden("total_itbm"+i,""+total_itbm)%>
			<%=fb.hidden("tipo_art"+i,""+cdo.getColValue("tipo_art"))%>
			<%=fb.hidden("tipo_articulo"+i,""+cdo.getColValue("tipo_articulo"))%>
			<%=fb.hidden("tipo_servicio"+i,""+cdo.getColValue("tipo_servicio"))%>
			<%=fb.hidden("afecta_inventario"+i,""+cdo.getColValue("afecta_inventario"))%>
			<%=fb.hidden("costo"+i,""+cdo.getColValue("costo"))%>
			<%=fb.hidden("cod_barra"+i,""+cdo.getColValue("cod_barra"))%>
			<%=fb.hidden("qty_ini"+i,""+cdo.getColValue("qty_ini"))%>
			<%=fb.hidden("val_desc"+i,""+cdo.getColValue("val_desc"))%>
			<%=fb.hidden("tipo_desc"+i,""+cdo.getColValue("tipo_desc"))%>
			<%=fb.hidden("xx_"+htDet.size()+"_"+cdo.getColValue("codigo").replace("@", "a").replace("-", "_"),cdo.getColValue("cantidad"))%>
			<%=fb.hidden("spn"+i, "codigo="+codigoSinSymb+"&descripcion="+issi.admin.IBIZEscapeChars.forURL(cdo.getColValue("descripcion"))+"&precio="+cdo.getColValue("precio")+"&itbm="+cdo.getColValue("itbm")+"&tipo_art="+cdo.getColValue("tipo_art")+"&codigo_almacen="+cdo.getColValue("codigo_almacen")+"&id_descuento="+cdo.getColValue("id_descuento")+"&tipo_descuento="+cdo.getColValue("tipo_descuento")+"&tipo_servicio="+cdo.getColValue("tipo_servicio")+"&gravable_perc="+cdo.getColValue("gravable_perc")+"&precio_app="+cdo.getColValue("precio_app")+"&precio_normal="+cdo.getColValue("precio_normal")+"&id_precio="+cdo.getColValue("id_precio")+"&total_desc="+cdo.getColValue("total_desc")+"&total_itbm="+cdo.getColValue("total_itbm")+"&tipo_articulo="+cdo.getColValue("tipo_articulo")+"&afecta_inventario="+cdo.getColValue("afecta_inventario")+"&costo="+cdo.getColValue("costo")+"&cod_barra="+cdo.getColValue("cod_barra")+"&qty_ini="+cdo.getColValue("qty_ini")+"&val_desc="+cdo.getColValue("val_desc")+"&tipo_desc="+cdo.getColValue("tipo_desc")+"&use_keypad="+keypad+"&touch="+touch)%>
			<!--<tr class="<%=(cdo.getColValue("tipo_art").equals("D")?"RedText":(cdo.getColValue("precio_app").equals("S")?"YellowTextBold":color))%>" align="center" style="height:35px;">-->
			<tr class="<%=(cdo.getColValue("tipo_art").equals("D")?(cdo.getColValue("tipo_desc").equals("E")?"YellowTextBold":"RedTextBold"):color)%>" align="center" style="height:35px;">
				<td align="left" onDblClick="javascript:changeDesc(<%=i%>);" style="cursor:pointer">
                <%=cdo.getColValue("itbm").equalsIgnoreCase("S") && cdo.getColValue("tipo_art").equalsIgnoreCase("N") && cdo.getColValue("gravable_perc").equals("0")? "<span title='ITBM = 0'>*</span>":""%>
                <%=(cdo.getColValue("tipo_art").equals("D")?(cdo.getColValue("tipo_desc").equals("E")?"(E)":"(J)"):"")%><%=cdo.getColValue("descripcion")%></td>
								<%//System.out.println("codigo despues del descuento...."+cdo.getColValue("codigo"));%>
				<%if(cdo.getColValue("tipo_art").equals("N") && !vDesc.contains(cdo.getColValue("codigo")) && cdo.getColValue("precio_app").equals("N")){%>
				<td onClick="javascript:descontar(<%=i%>);" style="cursor:pointer"><img src="../images/dollar_circle.gif" alt="" class="LinkImg" height ="<%=height%>" width="<%=width%>" border = "0" /></td>
			<%} else {%><td>&nbsp;</td><%}%>
				<td>
				<%=fb.decBox("cantidad"+i, cdo.getColValue("cantidad"), true, false, (!cdo.getColValue("tipo_descuento").equals("") || (cdo.getColValue("precio_app")!=null && cdo.getColValue("precio_app").equals("S"))), 3, 12.4, (useKeypad?"qty-use-keypad":""), "", !useKeypad?"onChange=\"javascript:calcRegTotal("+i+")\"":"", "", false, "data-i="+i, "")%>
				<%=fb.hidden("_cantidad"+i,cdo.getColValue("qty_ini"))%>
				</td>
				<td align="right"><%=CmnMgr.getFormattedDecimal("########0.0000", cdo.getColValue("precio"))%></td>
				<td align="right"><%=fb.decBox("total"+i, CmnMgr.getFormattedDecimal("########0.00", cdo.getColValue("total")), true, false, true, 4, 12.4, "text10", "", "", "", false, "", "")%></td>
				<td align="center">
				<%if(profUpd.trim().equals("S")){%><input type="button" class="btn btn-sm " id="rem<%=i%>" name="rem<%=i%>" value="X" onClick="javascript:borrar('<%=i%>');"><%}%>
				
				</td>
			</tr>
			<%}
			if (htPA.size() > 0) al = CmnMgr.reverseRecords(htPA, false);
			for (int i=0; i<htPA.size(); i++){
				key = al.get(i).toString();
				cdo = (CommonDataObject) htPA.get(key);
				////System.out.println("precios aplicado ...... articulo "+key);
			%>
			<%=fb.hidden("codigo_pa"+i,cdo.getColValue("codigo"))%>
			<%=fb.hidden("precio_pa"+i,cdo.getColValue("precio"))%>
			<%
			}
			if (htDet.size() > 0) al = CmnMgr.reverseRecords(htDesc, false);
			for (int i=0; i<htDesc.size(); i++){
				key = al.get(i).toString();
				cdo = (CommonDataObject) htDesc.get(key);
				////System.out.println("descuento..."+cdo.getColValue("codigo")+", precio..."+cdo.getColValue("precio")+", cantidad..."+cdo.getColValue("cantidad"));
			%>
			<%=fb.hidden("codigo_d"+i,cdo.getColValue("codigo").replace("@D@", ""))%>
			<%=fb.hidden("precio_d"+i,cdo.getColValue("precio"))%>
			<%=fb.hidden("cantidad_d"+i,cdo.getColValue("cantidad"))%>
			<%
			}
			%>
			<%=fb.hidden("detSize",""+htDet.size())%>
			<%=fb.hidden("detSizePA",""+htPA.size())%>
			<%=fb.hidden("descSize",""+htDesc.size())%>
			<%=fb.formEnd(true)%>
		</table>
	</td>
</tr>
</table>
<%}%>