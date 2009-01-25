


import java.io.ByteArrayOutputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.PrintStream;
import java.io.UnsupportedEncodingException;
import java.util.ArrayList;
import java.util.Collection;
import java.util.Enumeration;
import java.util.HashMap;
import java.util.HashSet;
import java.util.LinkedList;
import java.util.List;
import java.util.Stack;

import javax.swing.tree.TreeModel;

import edu.stanford.smi.protege.model.Cls;
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
	
    
    private int skippedClasses = 0;
    private int skippedForNoLabel = 0;
    private int handledClasses = 0;
    private HashMap<String, String> labelsMap = new HashMap<String, String>();
    private HashMap<String, String> labelsReverseMap = new HashMap<String, String>();
    

	ByteArrayOutputStream file2 = new ByteArrayOutputStream();
	FileOutputStream out = null;
   
	Slot rdfsLabel;
    public ProtegeOWLTreeGenerator() {

    	try {
			out = new FileOutputStream("etc/NIF-tree.xml");
		} catch (FileNotFoundException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
    }
    
    public void createOWLGraph() {
        	loadOntology();
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
    		JenaOWLModel owlModel = 
    			ProtegeOWL.createJenaOWLModelFromURI("http://ontology.neuinfo.org/NIF/nif.owl");
			
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

    			Slot rdfsLabel = owlModel.getSlot("rdfs:label");
    			String label = (String)entity.getDirectOwnSlotValue(rdfsLabel);
    			String prefix = owlModel.getPrefixForResourceName(entity.getName());
    			if (prefix != null) {
    				label =  prefix + ":" + label;
    			}
  
    	    	PrintStream s = new PrintStream(file2);
    			writeOut("<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n");
    			writeOut("<tree>\n");
    	    	    	    	
    	    	loadClassIntoTreeMLWithGUI(owlModel, file2, out);
    	    	

    			file2.writeTo(out);
    	    	file2.flush();
    	    	file2.close();
    	    	out.flush();
    	    	out.close();
    		}
    	} catch (Exception e) {
    		e.printStackTrace();
    	}	
    }
    
    private void writeOut(String s) {
    	
		try {
			file2.write(s.getBytes("UTF-8"));
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
    }
    
    /* Writes TreeML to disk as processing.
     * 
     * Builds up a stack, q, composed of SubsumptionTreeNodes, that themselves contain Cls's
     * The fact that Cls's are in LinkedLists allows the grouping of siblings and the 
     * correct placement of </branch> markers.
     */
    private void loadClassIntoTreeMLWithGUI(JenaOWLModel owlModel, ByteArrayOutputStream file2, FileOutputStream out) {

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
    	
    	String[] propLabels = {"birn_annot:bamsID", "birn_annot:bonfireID", "obo_annot:acronym", 
    			"obo_annot:synonym", "obo_annot:modifiedDate", 
    			"birn_annot:birnlexDefinition", "core:definition", "core:prefLabel", 
    			"birn_annot:hasCurationStatus", "obo_annot:UmlsCui", "rdfs:comment", 
    			"birn_annot:neuronamesID", "obo_annot:hasAbbrevSource", "obo_annot:abbrev", 
    			"obo_annot:definingCitation", "core:editorialNote", "obo_annot:externallySourcedDefinition", 
    			"obo_annot:hasDefinitionSource", "core:example", "birn_annot:hasBirnlexCurator",
    			"obo_annot:createdDate", "birn_annot:ncbiTaxScientificName", "birn_annot:ncbiTaxID",
    			"birn_annot:gbifTaxonKeyID", "birn_annot:gbifID", "obo_annot:misspelling", 
    			"birn_annot:itisID", "obo_annot:taxonomicCommonName"
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
			
			
						
			//get the id for this node
			String[] slotParts = n.getCls().getName().split(":");
			String id = n.getCls().getName();
			if (slotParts.length > 1)
				id = slotParts[1];
			
            //get the label and prefix for this node
			label = (String)n.getCls().getDirectOwnSlotValue(rdfsLabel);
			
			//if no label, skip this guy, because most likely it is
			//an anonymous class that we don't care about anyway.
			if (label == null) {
				//System.out.println("id " + id + " has no label");
				skippedForNoLabel++;
				skippedClasses++;
				continue;
			}
			//clean up the string for the label
			label = cleanString(label);
			
			String duplicateId = null;
			//search for duplicates, and if found, add id
			if (labelsMap.get(label.toLowerCase()) == null) {
				labelsMap.put(label.toLowerCase(), id);
				labelsReverseMap.put(id, label.toLowerCase());
			} else {
				duplicateId = labelsMap.get(label.toLowerCase());
				label += " (" + id + ")";
				String newLabel = label;
				//because we have changed the label, update the map we will
				//use to lookup parent labels via their ids
				labelsReverseMap.put(id, newLabel);
				System.out.println("duplicate label! Fixed version:" + label);
			}
			
			//HANDLE PARENT LABELS
			//get the label for the super class of this class
			String parentLabel = null;
			Collection sc = n.getCls().getDirectSuperclasses();
			ArrayList list = new ArrayList();
			list.addAll(sc);
			String parentId = null;
			for (int i = 0; i < n.getCls().getDirectSuperclassCount(); i++) {
				Cls superclass = (Cls)list.get(i);
				//get the id for this node
				String[] slotParts2 = superclass.getName().split(":");
				parentId = superclass.getName();
				
				if (slotParts2.length > 1)
					parentId = slotParts2[1];
				
				//this is only a temporary parent label assignment\
				//just needed to make sure this is not an anonymous class
				parentLabel = (String)superclass.getDirectOwnSlotValue(rdfsLabel);
				if (parentLabel != null) {
					break;
				}
			}
						
			if (parentLabel == null) {
				System.out.println("No parent for class " + label);
			} else {
				//use the reverse map because we have augmented some 
				//names with their ids and we want to be 
				//pointing to the correct parent label.
				parentLabel = labelsReverseMap.get(parentId);
				
				if (parentLabel == null) {
					System.out.println("No parent label? " + parentId);
					skippedClasses++;
					continue;
				}
			}

			//we are handling a class...add it to the sum
			handledClasses++;
			//OK, WE ARE SATISFIED THAT WE SHOULD START WRITING ABOUT THIS CLASS!
			
			writeOut("<leaf>\n");
			
			//write the label out
			writeOut("<attribute name=\"label\" value=\"" + label + "\"/>\n");
			
			if (duplicateId != null) {
				//write the duplicate Id out if applicable
				writeOut("<attribute name=\"duplicateId\" value=\"" + duplicateId + "\"/>\n");
			}
			//write the parent out

			if (parentLabel != null) {
				parentLabel = cleanString(parentLabel);
				writeOut("<attribute name=\"parent\" value=\"" + parentLabel + "\"/>\n");
			}
			
			prefix = owlModel.getPrefixForResourceName(n.getCls().getName());
			if (prefix != null) {
				writeOut("<attribute name=\"prefix\" value=\"" + prefix + "\"/>\n");
			}
			
			//write out id
			writeOut("<attribute name=\"id\" value=\"" + id + "\"/>\n");
			
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

						writeOut("<attribute name=\""+ slot.getName() + 
								"\" value=\"" + slotValue + "\"/>\n");
					}
				}
				slotValues.clear();
			}
			
			//close leaf tag if leaf.  We handle closing branch tags down below
			
			writeOut("</leaf>\n");	

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
			
			testSet.clear();
			//for all the nodes in the queue, add all their ancestors into testSet
			for (SubsumptionTreeNode t : q) {
				testSet.addAll(ancestorMap.get(t));
			}
		}
		writeOut("</tree>");
    }
   
    protected String cleanString(String s) {
    	try {
    		if (s.startsWith("~#en ")) {
				s = s.substring(5);
			}
			s = s.replaceAll("&", "&amp;");
    		s = s.replaceAll("\"", "&quot;");
    		s = s.replaceAll("\'", "&apos;");
    		s = s.replaceAll("\\[", "(");
    		s = s.replaceAll("\\]", ")");
    		s = s.replaceAll("<", "&lt;");
    		s = s.replaceAll(">", "&gt;");
    		
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
    	System.out.println("Ontology loading completed.");
    	System.out.println("Loaded " + potg.handledClasses + " classes");
    	System.out.println("Skipped " + potg.skippedClasses + " classes");
    	System.out.println("No label skips: " + potg.skippedClasses + " classes");
    }
}
