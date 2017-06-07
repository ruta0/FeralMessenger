//
//  MPCManager.swift
//  FeralMessenger
//
//  Created by rightmeow on 6/7/17.
//  Copyright © 2017 Duckisburg. All rights reserved.
//

import UIKit
import MultipeerConnectivity


protocol MPCManagerDelegate {
    
    func foundPeer()
    func lostPeer()
    func didReceivedInvitation(fromPeer: String, group: String)
    func didConnect(fromPeer: String, group: String)
    
}


class MPCManager: NSObject {
    
    private let serviceType = "Duckisburg.Feral"
    
    var initationHandler: ((Bool, MCSession?) -> Void)!
    var invitationHandler: ((Bool, MCSession?) -> Void)!
    
    var delegate: MPCManagerDelegate?
    var session: MCSession!
    var group: String!
    var peer: MCPeerID!
    var browser: MCNearbyServiceBrowser!
    var advertiser: MCNearbyServiceAdvertiser!
    
    var foundPeers = [MCPeerID]()
    
    func sendData(dictionaryWithData dictionary: Dictionary<String, String>, toPeer targetPeer: MCPeerID) -> Bool {
        let dataToSend = NSKeyedArchiver.archivedData(withRootObject: dictionary)
        do {
            try session.send(dataToSend, toPeers: [targetPeer], with: MCSessionSendDataMode.reliable)
            return true
        } catch let err {
            print(err.localizedDescription)
            return false
        }
    }
    
    override init() {
        super.init()
        // peer must be the first one to be initialized
        peer = MCPeerID(displayName: UIDevice.current.name) // handle this with the actual username of the Feral
        session = MCSession(peer: peer)
        session.delegate = self
        
        // (a) It mustn’t be longer than 15 characters, and (b) it can contain only lowercase ASCII characters, numbers and hyphens.
        browser = MCNearbyServiceBrowser(peer: peer, serviceType: serviceType)
        browser.delegate = self
        
        advertiser = MCNearbyServiceAdvertiser(peer: peer, discoveryInfo: nil, serviceType: serviceType)
        advertiser.delegate = self
    }
    
}


extension MPCManager: MCSessionDelegate {
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL, withError error: Error?) {
        
    }
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        
    }
    
    func session(_ session: MCSession, didReceiveCertificate certificate: [Any]?, fromPeer peerID: MCPeerID, certificateHandler: @escaping (Bool) -> Void) {
        
    }
    
}


extension MPCManager: MCNearbyServiceBrowserDelegate {
    
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        delegate?.lostPeer()
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        delegate?.foundPeer()
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
        print(error.localizedDescription)
    }
    
}


extension MPCManager: MCNearbyServiceAdvertiserDelegate {
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        self.invitationHandler = invitationHandler
        delegate?.didReceivedInvitation(fromPeer: peerID.displayName, group: group)
    }
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
        print(error.localizedDescription)
    }
    
    
}


























