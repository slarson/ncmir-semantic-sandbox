


import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.PrintStream;
import java.io.UnsupportedEncodingException;
import java.util.ArrayList;
import java.util.Collection;
import java.util.Enumeration;
import java.util.HashMap;
import java.util.HashSet;
import java.util.LinkedList;
import java.util.List;
import java.util.Locale;
import java.util.Stack;

import javax.swing.tree.TreeModel;

import jena.schemagen;

import prefuse.data.Node;
import prefuse.data.Tree;
import edu.stanford.smi.protege.model.Cls;
import edu.stanford.smi.protege.model.Project;
import edu.stanford.smi.protege.model.Slot;
import edu.stanford.smi.protege.util.ApplicationProperties;
import edu.stanford.smi.protegex.owl.ProtegeOWL;
import edu.stanford.smi.protegex.owl.jena.JenaOWLModel;
import edu.stanford.smi.protegex.owl.ui.subsumption.AssertedSubsumptionTreePanel;
import edu.stanford.smi.protegex.owl.ui.subsumption.SubsumptionTreeNode;
import edu.stanford.smi.protegex.owl.ui.subsumption.SubsumptionTreeRoot;


/**
 * Loads an on-disk version of the NIFSTD ontology using the Protege API.  Writes the ontology 
 * out as a single TreeML document.  Document is too big to fit in memory, so it is streamed
 * directly to disk.
 * 
 * Last modified 08/27/08
 * 
 * @author Stephen D. Larson
 * 
 *
 */
public class ProtegeOWLTreeGenerator {
	
    Tree g;
    HashMap<String,Cls> hm;
   
	Slot rdfsLabel;
    public ProtegeOWLTreeGenerator() {
    	g = new Tree();
    	g.addColumn("label", String.class);
    	
		//g.addColumn("owlClass", Cls.class);
    	hm = new HashMap<String,Cls>();
    }
    
    public void createOWLGraph() {
            
        	loadOntology();
            
        	/*
            Node root = this.getGraph().addNode();
            root.set("label", "root");
            for (Iterator it = this.getGraph().nodes(); it.hasNext();) {
            	Node n = (Node)it.next();
            	if (this.getGraph().getInDegree(n) < 1) {
            		if (!"root".equals(n.get("label"))) {
            			this.getGraph().addEdge(root, n);
            		}
            	}
            }*/
        	
        	System.out.println(g.isValidTree());

    }
    
    private void loadOntology() {
    	try {

    		//JenaOWLModel owlModel = ProtegeOWL.createJenaOWLModelFromURI("http://ccdb.ucsd.edu/SAO/1.2.9/SAO.owl");
    		
    		
    		ApplicationProperties.setUrlConnectTimeout(100000);
			ApplicationProperties.setUrlConnectReadTimeout(100000);
			System.getProperties().put("proxySet", "true");
			System.getProperties().put("proxyPort", "8080");
			System.getProperties().put("proxyHost", "http://webproxy.ucsd.edu/proxy.pl");
			
			/* load from web */
			//JenaOWLModel owlModel = ProtegeOWL.createJenaOWLModelFromURI("http://purl.org/nbirn/birnlex/ontology/BIRNLex-Anatomy.owl");
    		JenaOWLModel owlModel = ProtegeOWL.createJenaOWLModelFromURI("http://ontology.neuinfo.org/NIF/1.0/NIF1.0.owl");
			
			/* load from disk strategy: */
			//ProjectManager projectManager = ProjectManager.getProjectManager();
			//Project p = Project.loadProjectFromFile("C:/Documents and Settings/stephen/Desktop/nifSaved/nif.pprj", new ArrayList());						
			//JenaOWLModel owlModel = (JenaOWLModel) p.getKnowledgeBase();

    		
    		//must be done before getLabel() is run!!!
    		rdfsLabel = owlModel.getSlot("rdfs:label");
    		
    		if (owlModel != null) {

    			Cls root = owlModel.getRootCls();
    			Cls entity = owlModel.getCls("bfo:Entity");
    			System.out.println("The root class is: " + entity.getName());
    			Node rootNode = getTree().addRoot();
    			Slot rdfsLabel = owlModel.getSlot("rdfs:label");
    			String label = (String)entity.getDirectOwnSlotValue(rdfsLabel);
    			String prefix = owlModel.getPrefixForResourceName(entity.getName());
    			if (prefix != null) {
    				label =  prefix + ":" + label;
    			}
    			rootNode.setString("label", label);
    			hm.put(label, entity);
    			
    			FileOutputStream file2 = null;
    			try {
    				file2 = new FileOutputStream("etc/NIF-tree.xml");
    			} catch (FileNotFoundException e) {
    				// TODO Auto-generated catch block
    				e.printStackTrace();
    			}
    	    	
    	    	PrintStream s = new PrintStream(file2);
    	    	s.println("<?xml version=\"1.0\" encoding=\"UTF-8\"?>");
    	    	s.println("<tree>");
    	    	//s.println("<!DOCTYPE tree SYSTEM \"treeml.dtd\"><!DOCTYPE tree SYSTEM \"treeml.dtd\">");
    	    	s.println("<declarations><attributeDecl name=\"label\" type=\"String\"/></declarations>");
    	    	
    	    	loadClassIntoTreeMLWithGUI(owlModel, s);

    		}
    	} catch (Exception e) {
    		e.printStackTrace();
    	}	
    }
    
    /* Writes TreeML to disk as processing.
     * 
     * Builds up a stack, q, composed of SubsumptionTreeNodes, that themselves contain Cls's
     * The fact that Cls's are in LinkedLists allows the grouping of siblings and the 
     * correct placement of </branch> markers.
     */
    private void loadClassIntoTreeMLWithGUI(JenaOWLModel owlModel, PrintStream s) {

    	//use the protege GUI class, AssertedSubsumptionTreePanel, to access the
    	//class hierarchy of this owlModel
    	AssertedSubsumptionTreePanel pane = new AssertedSubsumptionTreePanel(owlModel);
    	TreeModel m = pane.getClsesTree().getModel();
    	SubsumptionTreeRoot fakeRoot = (SubsumptionTreeRoot) m.getRoot();
    	
    	//the root of this class hierarchy
    	SubsumptionTreeNode root = (SubsumptionTreeNode)fakeRoot.children().nextElement();
    	
    	//find the "bfo:entity" node from the first level of the hierarchy
    	//so we can use it to start our tree crawl
    	SubsumptionTreeNode entity = null;
    	Enumeration firstLevel = root.children();
    	String label, prefix;
    	while(firstLevel.hasMoreElements()) {
    		SubsumptionTreeNode next = (SubsumptionTreeNode)firstLevel.nextElement();
    		 //how to get the label for this node
			label = (String)next.getCls().getDirectOwnSlotValue(rdfsLabel);
			prefix = owlModel.getPrefixForResourceName(next.getCls().getName());
			if (prefix != null) {
				label =  prefix + ":" + label;
			}
			if ("bfo:entity".equals(label)) {
				entity = next;
			}
    	}
    	//verify that we found it, if not, quit.
    	if (entity == null) {
    		System.out.println("can't find bfo:entity!");
    		return;
    	}
    	
    	//start with the entity node as our new root.
    	root = entity;
    	
    	label = "label";
    	prefix = null;
    	
    	String[] propLabels = {"birn_annot:bonfireID", "j.0:acronym", "j.0:synonym", "j.0:modifiedDate", 
    			"birn_annot:birnlexDefinition", "core:definition", "core:prefLabel", 
    			"birn_annot:hasCurationStatus", "j.0:UmlsCui", "rdfs:comment", 
    			"birn_annot:neuronamesID", "j.0:hasAbbrevSource", "j.0:abbrev", 
    			"j.0:definingCitation", "core:editorialNote", "j.0:externallySourcedDefinition", 
    			"j.0:hasDefinitionSource", "core:example", "birn_annot:hasBirnlexCurator",
    			"j.0:createdDate", "birn_annot:ncbiTaxScientificName", "birn_annot:ncbiTaxID",
    			"birn_annot:gbifTaxonKeyID", "birn_annot:gbifID", "j.0:misspelling", 
    			"birn_annot:itisID", "j.0:taxonomicCommonName"
    			};
    	
    	List<Slot> slots = new ArrayList<Slot>();
    	for (int i = 0; i < propLabels.length; i++) {
    		Slot s2 = owlModel.getSlot(propLabels[i]);
    		if (s2 != null) {
    			slots.add(s2);
    		} else {
    			System.out.println("WARNING: Slot " + propLabels[i] + " does not exist");
    		}
    	}
    	
    	
    	//the stack!
    	Stack<SubsumptionTreeNode> q = new Stack<SubsumptionTreeNode>();
    	HashMap<SubsumptionTreeNode, LinkedList<SubsumptionTreeNode>> ancestorMap = 
    		new HashMap<SubsumptionTreeNode, LinkedList<SubsumptionTreeNode>>();
    	//first iteration for parent
		q.push(root);
		LinkedList<SubsumptionTreeNode> ancestorList = new LinkedList<SubsumptionTreeNode>();
		ancestorMap.put(root, ancestorList);
		
		//set to test ancestors
		HashSet<SubsumptionTreeNode> testSet = new HashSet<SubsumptionTreeNode>();
		List<String> slotValues = new ArrayList<String>();
		
		//so long as the stack is not empty
		while (q.size() > 0) {
			//get a node
			SubsumptionTreeNode n = q.pop();
			
						
            //get the label and prefix for this node
			label = (String)n.getCls().getDirectOwnSlotValue(rdfsLabel);
			//if no label, skip this guy
			if (label == null) continue;
			label = cleanString(label);
			
			//HANDLE PARENT LABELS
			//get the label for the super class of this class
			String parentLabel = null;
			Collection sc = n.getCls().getDirectSuperclasses();
			ArrayList list = new ArrayList();
			list.addAll(sc);
			for (int i = 0; i < n.getCls().getDirectSuperclassCount(); i++) {
				Cls superclass = (Cls)list.get(i);
				parentLabel = (String)superclass.getDirectOwnSlotValue(rdfsLabel);
				if (parentLabel != null) {
					break;
				}
			} 
			
			if (parentLabel == null) {
				System.out.println("No parent for class " + label);
			} else {
				//if the parent label is the same as the label, skip this class.
				//don't render items that have the same parent label as itself
				//need to investigate why these exist (NIF-molecule)
				if (parentLabel.equals(label)){
					continue;
				}
			}

			//OK, WE ARE SATISFIED THAT WE SHOULD START WRITING ABOUT THIS CLASS!
			
			//open leaf tag if leaf, branch tag if tag
			if (n.isLeaf()) {
				s.println("<leaf>");
			} else {
				s.println("<branch>");
			}
			//write the label out
			s.println("<attribute name=\"label\" value=\"" + label + "\"/>");
			
			//write the parent out

			if (parentLabel != null) {
				parentLabel = cleanString(parentLabel);
				s.println("<attribute name=\"parent\" value=\"" + parentLabel + "\"/>");
			}
			
			prefix = owlModel.getPrefixForResourceName(n.getCls().getName());
			if (prefix != null) {
				s.println("<attribute name=\"prefix\" value=\"" + prefix + "\"/>");
			}
			
			//get the id for this node
			String[] slotParts = n.getCls().getName().split(":");
			String slotValue2 = n.getCls().getName();
			if (slotParts.length > 1)
				slotValue2 = slotParts[1];

			s.println("<attribute name=\"id\" value=\"" + slotValue2 + "\"/>");
			
			//print out names and values of other slots that might be there
			for (Slot slot : slots) {
				if (slot == null) {
					System.err.println("Could not find a slot!");
					continue;
				}
				slotValues.addAll(n.getCls().getDirectOwnSlotValues(slot));
				
				if (!slotValues.isEmpty()) {

					for (String slotValue : slotValues) {
						slotValue = cleanString(slotValue);

						s.println("<attribute name=\""+ slot.getName() + 
								"\" value=\"" + slotValue + "\"/>");
					}
				}
				slotValues.clear();
			}
			
			//close leaf tag if leaf.  We handle closing branch tags down below
			if (n.isLeaf()) {
				s.println("</leaf>");	
			}

			//get the children for this node
			Enumeration subclasses = n.children();
			//iterate over the node children
			for(;subclasses.hasMoreElements();) {
				SubsumptionTreeNode next = (SubsumptionTreeNode)subclasses.nextElement();
				q.add(next);
				
				// create ancestor list for this node 
				ancestorList = new LinkedList<SubsumptionTreeNode>();
				//my ancestors are my parent's ancestors plus my parent.
				if (next.getParent() instanceof SubsumptionTreeNode) {
					SubsumptionTreeNode p = (SubsumptionTreeNode)next.getParent();
					ancestorList.addAll(ancestorMap.get(p));
					ancestorList.add(p);
				}
				// add ancestor list to ancestorMap 
				ancestorMap.put(next, ancestorList);
				
			}
			s.flush();
			
			testSet.clear();
			//for all the nodes in the queue, add all their ancestors into testSet
			for (SubsumptionTreeNode t : q) {
				testSet.addAll(ancestorMap.get(t));
			}
			/* If I have a unique ancestors compared to the rest of the nodes
			 * left in the queue, then I need to be responsible
			 * for closing the branch for those ancestors
			 */
			for (SubsumptionTreeNode t : ancestorMap.get(n)) {
				if (!testSet.contains(t)) {
					s.println("</branch>");	
				}
			}
		}
		s.println("</tree>");
    }

    public Tree getTree() {
    	return g;
    }
   
    protected String cleanString(String s) {
    	try {
    		if (s.startsWith("~#en ")) {
				s = s.substring(5);
			}
			s = s.replaceAll("&", "&amp;");
    		s = s.replaceAll("\"", "&quot;");
    		s = s.replaceAll("\'", "&apos;");
			return new String(s.getBytes("UTF-8"));
		} catch (UnsupportedEncodingException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		return null;
    }
    
    public static void main(String[] args) {
    	
    	ProtegeOWLTreeGenerator potg = new ProtegeOWLTreeGenerator();
    	potg.loadOntology();
    }
}
